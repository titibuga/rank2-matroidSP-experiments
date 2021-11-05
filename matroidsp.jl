using Random

GLOBAL_DBG = false

function dbg_println(str)
    if GLOBAL_DBG
        println(str)
    end
end



struct Item
    inner_class
    weight
end


# Tries to add item to current_opt if it improves the weight and can be added (that is, final opt is independent and the replaced item, if any, was not fixed). Also fixes the item added (doesn't have effect in the simulation if no fixed vector was passed as a parameter).

function addImprovingItem!(current_opt, item; fixed = [false, false])
    
    # Maybe there is a better way to do it, but I'll do it in the simple way

    dbg_println("===== Starting addImprovingItem =====")
    dbg_println("[AII]> current_opt: $current_opt")
    dbg_println("[AII]> Item to be added: $item")
    dbg_println("[AII]> Fixed items vec: $fixed")

    if length(current_opt) == 0

        dbg_println("[AII]==> Item added in empty current_opt!")
        push!(current_opt, item)
        fixed[1] = true
        return true

    elseif length(current_opt) == 1

        if current_opt[1].inner_class != item.inner_class
            dbg_println("[AII]==> Item added in current_opt of size 1!")
            push!(current_opt, item)
            fixed[2] = true
            return true
        elseif !fixed[1] && current_opt[1].weight < item.weight
            dbg_println("[AII]==> Item replaced in current_opt of size 1!")
            current_opt[1] = item
            fixed[1] = true
            return true
        end

    else
        dbg_println("[AII]==> Opt of size 2!")
        if (current_opt[1].inner_class != item.inner_class) && (current_opt[2].inner_class != item.inner_class)

            # Replace min value that is replaceable
            dbg_println("[AII]==> New class!")
            min_v, min_i = findmin([i.weight for i in current_opt])
            dbg_println("[AII]==> min value in opt: $min_v | index: $min_i")
            if !fixed[min_i] && min_v < item.weight
                current_opt[min_i] = item
                fixed[min_i] = true
                dbg_println("[AII]==> Replaced min!")
                return true
            else
                dbg_println("[AII]==> Trying max!")
                other_i = (min_i % 2) + 1
                if !fixed[other_i] && current_opt[other_i].weight < item.weight
                    dbg_println("[AII]==> Replaced max!")
                    current_opt[other_i] = item
                    fixed[other_i] = true
                    return true
                end
            end

        else # There is a item in opt with same inner class
            dbg_println("[AII]==> Class clash!")

            # Find clash and check if we can replace it
            clash_id = 0
            for i in 1:2
                if current_opt[i].inner_class == item.inner_class
                    clash_id = i
                end
            end
            dbg_println("[AII]> Clash index: $clash_id | Item: $(current_opt[clash_id])")

            if !fixed[clash_id] && current_opt[clash_id].weight < item.weight
                dbg_println("[AII]==> Replaced clash item!")
                current_opt[clash_id] = item
                fixed[clash_id] = true
                return true
            end   
        end
    end

    return false # Item wasn't added 


end


# Return OPT of item_list

function computeOPT(item_list)

    sorted_item_list = sort(item_list, lt = (a,b) -> a.weight < b.weight, rev = true)
    opt = Item[]

    for item in sorted_item_list
        if length(opt) >= 2
            break
        end
        addImprovingItem!(opt, item)
   end

   return opt
end


function greedy(item_list; p = 1/ℯ)

    #global GLOBAL_DBG = true

    dbg_println("==== Starting Greedy with p = $p =====")

    n = length(item_list)
    sample_size = Int(ceil(n*p))
    

    current_opt = computeOPT(item_list[1:sample_size])
    fixed = [false, false]

    dbg_println("> Sample size: $sample_size")
    dbg_println("> Sample:")
    dbg_println(item_list[1:sample_size])
    dbg_println("> Sample OPT: $current_opt")
    dbg_println("==> Starting to see items!")
    for item in item_list[sample_size+1:n]
        dbg_println("> Seeing: $item")
        #global GLOBAL_DBG = false
        item_added = addImprovingItem!(current_opt, item; fixed=fixed)
        #global GLOBAL_DBG = true
        if item_added
            dbg_println("==> Item added! New alg_OPT: $current_opt")
        end
    end

    # Remove non-fixed items since they were never actually picked
    final_opt = current_opt[fixed]

    return final_opt
end


function runSecretaryTrials(item_list, secretary_strategy; n_trials = 20)
    println("===== Starting trials! =====")
    OPT = computeOPT(item_list)
    sort!(OPT, lt = (a,b) -> a.weight < b.weight, rev = true)
    times_picked = [0,0]
    for trial in 1:n_trials
        shuffled_items = shuffle(item_list)
        alg_OPT = secretary_strategy(shuffled_items)

        sort!(alg_OPT, lt = (a,b) -> a.weight < b.weight, rev = true)
        if length(alg_OPT) < 2 #Avoids silly problems
            push!(alg_OPT, Item(-1,-1))
        end

        times_picked += [OPT[i] in alg_OPT for i in 1:length(OPT)] 
    end

    freq = times_picked/n_trials

    println("===== Trials done! ====")
    println("> Frequency of item 1: $(freq[1])")
    println("> Frequency of item 2: $(freq[2])")

end


###################################################
############## Instance Generators ################
###################################################

function createOneThirdInstance(n)
    
    function classId(i)
        if i < n/3
            return 1
        elseif i < 2n/3
            return 2
        else
            return i
        end
    end

    return [Item(classId(i), n - i + 1) for i in 1:n]

end

function createUniformInstance(n)

    return [Item(i,i) for i in 1:n]

end