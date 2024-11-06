function init(args)
    local needs = {}
    needs["dns.rrname"] = tostring(true)  -- Register dns.rrname for domain name inspection
    return needs
end

function log2 (x) return math.log(x) / math.log(2) end

-- Calculate entropy for domain names
function calculate_entropy(domain)
    local N = domain:len()
    if N == 0 then return 0 end  -- avoid division by zero
    
    local count = {}
    for i = 1, N do
        local char = domain:sub(i, i)
        count[char] = (count[char] or 0) + 1
    end

    local sum = 0
    for _, freq in pairs(count) do
        local p = freq / N
        sum = sum + p * log2(p)
    end
    return -sum
end

-- Match function to check if a DNS request contains a high-entropy domain
function match(args)
    local domain = tostring(args["dns.rrname"])  -- Extract the DNS query domain name
    if domain and #domain > 0 then
        -- Calculate entropy and maximum possible entropy for Base64-like character set
        local entropy = calculate_entropy(domain)
        local max_entropy = log2(64) * domain:len()  -- Assume Base64 character set
        local entropy_ratio = entropy / max_entropy

        -- Trigger alert if entropy > 3 and entropy ratio >= 0.85
        if entropy > 3 and entropy_ratio >= 0.85 then
            return 1  -- Suspicious domain detected
        end
    end

    return 0  -- No alert if no suspicious domain found
end
