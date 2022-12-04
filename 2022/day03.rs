use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let file_path = args[1].clone();

    let contents = fs::read_to_string(file_path)
        .expect("Couldn't read file");

    let rucksacks: Vec<&str> = contents.split("\n").collect();

    let result_part_one: i32 = part_one(&rucksacks);
    println!("part one: {}", result_part_one);

    let result_part_two: i32 = part_two(&rucksacks);
    println!("part two: {}", result_part_two);
}

fn part_one(rucksacks: &Vec<&str>) -> i32 {
    let mut sum: i32 = 0;
    for rucksack in rucksacks {
        let num_of_items: usize = rucksack.len();
        let mut found: bool = false;
        let mut i: usize = 0;
        while i < num_of_items / 2 && !found {
            let item: u8 = rucksack.as_bytes()[i];
            let mut j: usize = num_of_items / 2;
            while j < num_of_items && !found {
                if item == rucksack.as_bytes()[j] {
                    if item >= 97 && item <= 122 {
                        sum += i32::from(item - 96);
                    } else if item >= 65 && item <= 90 {
                        sum += i32::from(item - 38);
                    } else {
                        println!("Error");
                    }

                    found = true;
                }
                j += 1;
            }
            i += 1;
        }
    }
    sum
}

fn part_two(rucksacks: &Vec<&str>) -> i32 {
    let mut sum: i32 = 0;
    let num_of_rucksacks: usize = rucksacks.len();
    let mut i: usize = 0;
    while i < num_of_rucksacks {
        let mut found: bool = false;
        let rucksack_1: &str = rucksacks[i];
        let mut j: usize = 0;
        while j < rucksack_1.len() && !found {
            let item: u8 = rucksack_1.as_bytes()[j];
            let rucksack_2: &str = rucksacks[i+1];
            let mut k: usize = 0;
            while k < rucksack_2.len() && !found {
                if item == rucksack_2.as_bytes()[k] {
                    let rucksack_3: &str = rucksacks[i+2];
                    let mut l: usize = 0;
                    while l < rucksack_3.len() && !found {
                        if item == rucksack_3.as_bytes()[l] {
                            if item >= 97 && item <= 122 {
                                sum += i32::from(item - 96);
                            } else if item >= 65 && item <= 90 {
                                sum += i32::from(item - 38);
                            } else {
                                println!("Error");
                            }

                            found = true;
                        }
                        l += 1;
                    }
                }
                k += 1;
            }
            j += 1;
        }
        i += 3;
    }
    sum
}