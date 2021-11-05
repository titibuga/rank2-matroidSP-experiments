using Test
include("matroidsp.jl")

@testset "Tests for 'addImprovingItem!()'" begin
    item_list = [Item(1,10), Item(1,30), Item(2,05), Item(2,20), Item(3,40), Item(3,0)]
    OPT = [item_list[5], item_list[2]]

    @testset "Trying to add to empty set" begin
        current_opt = []
        fixed = [false, false]
        addImprovingItem!(current_opt, item_list[1], fixed = fixed)
        @test length(current_opt) == 1 && current_opt[1] == item_list[1]
        @test fixed[1] = true
    end

    @testset "Trying to add to a set with one element" begin
        current_opt = [item_list[1]]

        # Should not add this item
        new_item = Item(1, 5)
        addImprovingItem!(current_opt, new_item)
        @test length(current_opt) == 1 && current_opt[1] == item_list[1]

        # Should replace current item if not fixed
        new_item = Item(1, 15)
        fixed = [true, false]
        addImprovingItem!(current_opt, new_item, fixed = fixed)
        @test length(current_opt) == 1
        @test item_list[1] in current_opt
        fixed[1] = false
        addImprovingItem!(current_opt, new_item, fixed = fixed)
        @test length(current_opt) == 1
        @test new_item in current_opt

        # Should add item 
        fixed = [false, false]
        new_item = Item(2,0)
        addImprovingItem!(current_opt, new_item, fixed = fixed)
        @test length(current_opt) == 2
        @test new_item == current_opt[2]
        @test fixed[2] == true 
    end

    @testset "Trying to add to a set with two elements" begin
        current_opt = [Item(1,10), Item(2,15)]
        original_opt = copy(current_opt)

        # Should not replace fixed items
        fixed = [true, false]
        addImprovingItem!(current_opt, Item(1, 11), fixed=fixed)
        @test current_opt[1] == original_opt[1]
        @test current_opt[2] == original_opt[2]
        @test fixed[2] == false
    end
end;