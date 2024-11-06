function log2(x) return math.log(x) / math.log(2) end

function entropy(domain)
    -- Strip non-alphanumeric and non-hyphen characters
    local cleaned_domain = domain:gsub("[^%w-]", "")
    
    local N = cleaned_domain:len()
    if N == 0 then return 0 end  -- do not divide by zero!
    
    -- Count character frequencies
    local count = {}
    for i = 1, N do
        local char = cleaned_domain:sub(i, i)
        count[char] = (count[char] or 0) + 1
    end
    
    -- Shannons entropy
    local sum = 0
    for _, freq in pairs(count) do
        local p = freq / N
        sum = sum + p * log2(p)
    end
    local calculated_entropy = -sum

    -- max possible entropy for the domain length (base-36)
    local max_entropy = log2(36) * N
    local entropy_ratio = calculated_entropy / max_entropy

    -- entropy threshold
    if calculated_entropy > 3 and entropy_ratio >= 0.85 then
        return 1
    else
        return 0
    end
end

function alert_if_suspicious_dns(tx)
    local domain = tx:dns_query_name()
    if domain and entropy(domain) == 1 then
        return 1  -- Trigger alert
    end
    return 0
end