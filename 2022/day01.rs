use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let file_path = args[1].clone();

    let contents = fs::read_to_string(file_path)
        .expect("Couldn't read file");

    let inventories: Vec<&str> = contents.split("\n\n").collect();

    let result_part_one: i32 = get_inventory_with_max_sum_calories(&inventories);
    println!("part one: {}", result_part_one);

    let result_part_two: i32 = get_top_3_inventories_with_max_sum_calories(&inventories);
    println!("part two: {}", result_part_two);
}

fn get_inventory_with_max_sum_calories(inventories: &Vec<&str>) -> i32 {
    let mut max_calories: i32 = 0;
    for inventory in inventories {
        let foods_calories: Vec<&str> = inventory.split("\n").collect();
        let mut sum: i32 = 0;
        for food_calories in foods_calories {
            sum += food_calories.parse::<i32>().unwrap();
        }
        if max_calories < sum {
            max_calories = sum;
        }
    }
    max_calories
}

fn get_top_3_inventories_with_max_sum_calories(inventories: &Vec<&str>) -> i32 {
    let mut inventories_sums: Vec<i32> = Vec::new();
    for inventory in inventories {
        let foods_calories: Vec<&str> = inventory.split("\n").collect();
        let mut sum: i32 = 0;
        for food_calories in foods_calories {
            sum += food_calories.parse::<i32>().unwrap();
        }
        inventories_sums.push(sum);
    }
    inventories_sums.sort();
    inventories_sums.reverse();
    inventories_sums[0] + inventories_sums[1] + inventories_sums[2]
}