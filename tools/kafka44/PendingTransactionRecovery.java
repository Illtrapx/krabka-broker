import java.util.List;
import java.util.Properties;
import org.apache.kafka.clients.admin.*;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.Uuid;
import org.apache.kafka.common.message.InitProducerIdResponseData;
import org.apache.kafka.common.message.InitProducerIdRequestData;
import org.apache.kafka.common.requests.InitProducerIdRequest;
import org.apache.kafka.common.requests.InitProducerIdResponse;

/** Caller-owned crash boundary: seed prints the exact identity; resolve never restarts endpoints. */
public class PendingTransactionRecovery {
    private static InitProducerIdResponseData initialize(String endpoint, String txn) throws Exception {
        return ((InitProducerIdResponse) TransactionScenarios.call("pending-init", endpoint,
            new InitProducerIdRequest.Builder(new InitProducerIdRequestData().setTransactionalId(txn)
                .setTransactionTimeoutMs(300000).setProducerId(-1).setProducerEpoch((short) -1)).build((short) 5))).data();
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 2) throw new IllegalArgumentException("seed ENDPOINT modern|legacy or resolve ENDPOINT TOPIC GROUP UUID TXN PID EPOCH commit|abort");
        boolean seed = args[0].equals("seed");
        if ((seed && (args.length != 3 || (!args[2].equals("modern") && !args[2].equals("legacy")))) ||
            (!seed && (!args[0].equals("resolve") || args.length != 9 || (!args[8].equals("commit") && !args[8].equals("abort")))))
            throw new IllegalArgumentException("invalid fixture mode");
        String endpoint = args[1];
        Properties config = new Properties();
        config.put("bootstrap.servers", endpoint);
        config.put("default.api.timeout.ms", "30000");
        try (Admin admin = Admin.create(config)) {
            if (seed) {
                String suffix = java.util.UUID.randomUUID().toString();
                String topic = "kafka44-pending-" + suffix;
                String group = "kafka44-pending-group-" + suffix;
                String txn = "kafka44-pending-txn-" + suffix;
                admin.createTopics(List.of(new NewTopic(topic, 1, (short) 1))).all().get();
                Uuid uuid = admin.describeTopics(List.of(topic)).allTopicNames().get().get(topic).topicId();
                if (uuid.equals(Uuid.ZERO_UUID)) throw new IllegalStateException("missing topic UUID");
                String groupEndpoint = TransactionScenarios.coordinator("pending-group-coordinator", endpoint, group, (byte) 0);
                String txnEndpoint = TransactionScenarios.coordinator("pending-txn-coordinator", endpoint, txn, (byte) 1);
                InitProducerIdResponseData producer = initialize(txnEndpoint, txn);
                short version = args[2].equals("modern") ? (short) 6 : (short) 5;
                TransactionScenarios.offsets("baseline-offset", groupEndpoint, txn, group, uuid, topic, producer, 7, version);
                TransactionScenarios.finish("baseline-commit", txnEndpoint, txn, producer, true);
                TopicPartition partition = new TopicPartition(topic, 0);
                TransactionScenarios.observed("baseline-visible", admin, group, partition, 7L, true);
                producer = initialize(txnEndpoint, txn);
                TransactionScenarios.offsets("pending-offset", groupEndpoint, txn, group, uuid, topic, producer, 42, version);
                TransactionScenarios.observed("pending-invisible-before-crash", admin, group, partition, 7L, false);
                System.out.println("PENDING\t" + topic + "\t" + group + "\t" + uuid + "\t" + txn + "\t" + producer.producerId() + "\t" + producer.producerEpoch());
            } else {
                String topic = args[2], group = args[3], txn = args[5];
                Uuid actual = admin.describeTopics(List.of(topic)).allTopicNames().get().get(topic).topicId();
                if (!actual.equals(Uuid.fromString(args[4]))) throw new IllegalStateException("crash changed topic incarnation");
                System.out.println("SCENARIO\tpending-crash-topic-id\tPASS");
                TopicPartition partition = new TopicPartition(topic, 0);
                TransactionScenarios.observed("pending-invisible-after-crash", admin, group, partition, 7L, false);
                String txnEndpoint = TransactionScenarios.coordinator("recovered-txn-coordinator", endpoint, txn, (byte) 1);
                InitProducerIdResponseData producer = new InitProducerIdResponseData().setProducerId(Long.parseLong(args[6])).setProducerEpoch(Short.parseShort(args[7]));
                boolean commit = args[8].equals("commit");
                TransactionScenarios.finish("pending-resolve-" + args[8], txnEndpoint, txn, producer, commit);
                TransactionScenarios.observed("pending-resolution-visible", admin, group, partition, commit ? 42L : 7L, true);
            }
        }
    }
}
