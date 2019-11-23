# tqdm allows for use of progress bars
require 'tqdm'

# Code below generates a .scratchpad file based
# on problem number in the filename of this script

$filename = __FILE__.sub '.rb', ''
$problem_number = $filename[/\d+/]
$scratchpad_filename = "euler_problem_"+$problem_number+".scratchpad"
$scratchpad = File.open($scratchpad_filename, "a")

# Method for writing to .scratchpad

$scratchpad_enabled = true

def pad(string)
    if $scratchpad_enabled
        $scratchpad.print string, "\n"
    end
end



# Code below loads lists of pre-generated prime numbers
# sorted by number of digits

$primes3dig = Array.new

File.open("primes3dig", "r") do |f|
    f.each_line do |line|
        $primes3dig.push(line.chomp.to_i)
    end
end

$primes4dig = Array.new

File.open("primes4dig", "r") do |f|
    f.each_line do |line|
        $primes4dig.push(line.chomp.to_i)
    end
end

$primes5dig = Array.new

File.open("primes5dig", "r") do |f|
    f.each_line do |line|
        $primes5dig.push(line.chomp.to_i)
    end
end

$primes6dig = Array.new

File.open("primes6dig", "r") do |f|
    f.each_line do |line|
        $primes6dig.push(line.chomp.to_i)
    end
end

$primes7dig = Array.new

File.open("primes7dig", "r") do |f|
    f.each_line do |line|
        $primes7dig.push(line.chomp.to_i)
    end
end

$primes8dig = Array.new

File.open("primes8dig", "r") do |f|
    f.each_line do |line|
        $primes8dig.push(line.chomp.to_i)
    end
end


# Main search methods below, smaller util methods further down

def get_valid_families (array_of_primes)
    pad("Looking for valid families among #{array_of_primes[0].to_s.length}-digit primes")
    all_families = find_sets_of_eight_plus_primes_sharing_digits(array_of_primes)
    valid_families = Array.new
    all_families.tqdm(desc: "searching for valid families", leave: true).each do |family|
        valid_primes = get_valid_primes(family)
        if valid_primes.length > 7 
            valid_families.push valid_primes
        end
    end
    pad("Found the following #{valid_families.length} valid families:")
    for family in valid_families
        pad(family)
    end
end

def get_valid_primes(family)
    common_digits = family[0]
    primes_in_family = family[1]
    skinned_primes = Array.new
    valid_primes = Array.new
    for prime in primes_in_family
        skinned_primes.push remove_common_digits(common_digits, prime)
    end
    for index in (0..skinned_primes.length-1)
        skinned_prime = skinned_primes[index]
        prime = primes_in_family[index]
        if are_digits_coequal(skinned_prime)
            valid_primes.push prime
        end
    end
    valid_primes
end

def find_sets_of_eight_plus_primes_sharing_digits(array_of_primes)
    pad(
        "Looking for families of eight or more primes\n"+
        "with common digits among #{array_of_primes[0].to_s.length}-digit primes"
    )
    families_of_eight_or_more = Array.new
    array_of_primes.tqdm(desc: "collecting sets", leave: true).each do |element|
        for element in find_families_for_candidate(array_of_primes, element)
            families_of_eight_or_more.push element
        end 
    end
    pad(
        "Found #{families_of_eight_or_more.length} families of eight or more among #{array_of_primes[0].to_s.length}-digit primes:"
    )
    families_of_eight_or_more
end

def find_families_for_candidate(array_of_primes, candidate=array_of_primes[0])
    candidate_member = candidate
    primes_that_share_digits_with_candidate = Array.new
    for prime in array_of_primes
        unless prime == candidate_member
            common_digits = find_common_digits(candidate_member, prime)
            if common_digits.length > 0
                primes_that_share_digits_with_candidate.push [prime, common_digits]
            end
        end
    end
    valid_families = aggregate_and_drop_families_smaller_than_eight(primes_that_share_digits_with_candidate)
    add_candidate_to_families(valid_families, candidate_member)
end




# Smaller util methods below, main search methods above

def find_common_digits(number1, number2)
    str1 = number1.to_s.split('')
    str2 = number2.to_s.split('')
    repeated_digits = []
    for index in (0..str1.length-1)
        if str1[index] == str2[index]
            repeated_digits.push([index, str1[index].to_i])
        end
    end
    repeated_digits
end

def aggregate_and_drop_families_smaller_than_eight(primes_that_share_digits_with_candidate)
    families = aggregate_by_common_digits(primes_that_share_digits_with_candidate)
    drop_families_smaller_than_eight(families)
end

def aggregate_by_common_digits (primes_that_share_digits_with_candidate)
    common_digits_already_sorted = Array.new
    sets_of_primes_with_the_same_digits_in_common = Hash.new
    for item in primes_that_share_digits_with_candidate
        prime = item[0]
        common_digits = item[1]
        unless common_digits_already_sorted.include? common_digits
            common_digits_already_sorted.push common_digits
            sets_of_primes_with_the_same_digits_in_common[common_digits] = Array.new
        end
        sets_of_primes_with_the_same_digits_in_common[common_digits].push prime
    end
    sets_of_primes_with_the_same_digits_in_common
end

def drop_families_smaller_than_eight(families)
    families_of_eight_or_more = Hash.new
    families.each do |key, value|
        if value.length >= 8
            families_of_eight_or_more[key] = value
        end
    end
    families_of_eight_or_more
end

def add_candidate_to_families(families, candidate)
    families.each_value do |value|
        value.push candidate
    end
end

def make_array (families)
    arr = Array.new
    families.each do |key, value|
        arr.push [key, value]
    end
    arr
end

def remove_common_digits (common_digits, prime)
    prime_s = prime.to_s
    for element in common_digits
        prime_s[element[0]] = "□"
    end
    prime_s.sub! "□", ""
    prime_s
end

def are_digits_coequal (number)
    digits = number.split('')
    for digit in digits
        if digit != digits[0]
            return false
        end
    end
    return true
end


# 'Main'-type method

def run
    header = "\n\n####################\n"+"Project Euler Problem "+$problem_number+"\n"+"####################"
    pad(header)
    time_begun = Time.now
    pad("Begun @ " + time_begun.to_s+"\n")

    get_valid_families($primes4dig)
    
    time_finished = Time.now
    pad("\nFinished @ " + time_finished.to_s)
    time_elapsed = time_finished - time_begun
    pad("Elapsed time: " + time_elapsed.to_s+"s")
end

run