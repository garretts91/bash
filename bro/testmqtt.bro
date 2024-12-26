export {
    redef enum Notice::Type += { Mqtt::Subscribe };
}

# Handle MQTT Subscribe events
event mqtt_subscribe(c: connection, msg_id: count, topics: string_vec, requested_qos: index_vec) {
    local wildcard_events: vector of string;  # Vector to store wildcard subscription events

    # Iterate through all topics in the packet
    for (i in 0 to |topics|-1) {
        if (topics[i] == "#") {
            # Store the wildcard subscription in the vector
            wildcard_events += fmt("Wildcard '#' subscription detected from %s", fmt("%s", c$id$orig_h));
        }
    }

    # Log each wildcard subscription event
    for (event in wildcard_events) {
        NOTICE([$note=Mqtt::Subscribe,
                $msg=event,
                $conn=c]);
    }

    # Final summary of all wildcard subscription events
    if (|wildcard_events| > 0) {
        NOTICE([$note=Mqtt::Subscribe,
                $msg=fmt("%s made %d wildcard subscribe requests in this packet.",
                         fmt("%s", c$id$orig_h), |wildcard_events|),
                $conn=c]);
    }
}
