use std::env;
use std::fs;
use std::collections::HashMap;

fn main() {
    let args: Vec<String> = env::args().collect();
    let file_path = args[1].clone();

    let contents = fs::read_to_string(file_path)
        .expect("Couldn't read file");

    let rounds: Vec<&str> = contents.split("\n").collect();

    let result_part_one: i32 = get_total_points(&rounds);
    println!("part one: {}", result_part_one);

    let result_part_two: i32 = get_total_points_different_plan(&rounds);
    println!("part two: {}", result_part_two);
}

fn get_total_points(rounds: &Vec<&str>) -> i32 {
    let mut rules: HashMap<&str, i32> = HashMap::new();
    rules.insert("A X", 3+1);
    rules.insert("A Y", 6+2);
    rules.insert("A Z", 0+3);
    rules.insert("B X", 0+1);
    rules.insert("B Y", 3+2);
    rules.insert("B Z", 6+3);
    rules.insert("C X", 6+1);
    rules.insert("C Y", 0+2);
    rules.insert("C Z", 3+3);

    let mut sum: i32 = 0;
    for round in rounds {
        sum += rules[round];
    }
    sum
}

fn get_total_points_different_plan(rounds: &Vec<&str>) -> i32 {
    let mut rules: HashMap<&str, i32> = HashMap::new();
    rules.insert("A X", 0+3);
    rules.insert("A Y", 3+1);
    rules.insert("A Z", 6+2);
    rules.insert("B X", 0+1);
    rules.insert("B Y", 3+2);
    rules.insert("B Z", 6+3);
    rules.insert("C X", 0+2);
    rules.insert("C Y", 3+3);
    rules.insert("C Z", 6+1);

    let mut sum: i32 = 0;
    for round in rounds {
        sum += rules[round];
    }
    sum
}