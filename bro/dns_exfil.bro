# DNS Exfiltration Detection Script
module DNS;

export {
    redef enum Notice::Type += {
        Exfiltration
    };
}

event dns_request(c: connection, msg: dns_msg, query: string, qtype: count, qclass: count)
{
    # Check if domain query length exceeds 52 characters
    if (|query| > 52) {
        NOTICE([$note=DNS::Exfiltration,
                $msg=fmt("Long Domain. Possible DNS exfiltration/tunnel by %s. Offending domain name: %s",
                         c$id$resp_h, query),
                $conn=c]);
    }
}
