use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let file_path = args[1].clone();

    let contents = fs::read_to_string(file_path)
        .expect("Couldn't read file");

    let pairs: Vec<&str> = contents.split("\n").collect();

    let result_part_one: i32 = part_one(&pairs);
    println!("part one: {}", result_part_one);

    let result_part_two: i32 = part_two(&pairs);
    println!("part two: {}", result_part_two);
}

fn part_one(pairs: &Vec<&str>) -> i32 { 
    let mut sum: i32 = 0;
    for pair in pairs {
        let mut split = pair.split(",");
        let pair_tuple = (split.next().unwrap(), split.next().unwrap());

        let mut split_range_1 = pair_tuple.0.split("-"); 
        let range_1 = (split_range_1.next().unwrap().parse::<i32>().unwrap(), split_range_1.next().unwrap().parse::<i32>().unwrap());
        
        let mut split_range_2 = pair_tuple.1.split("-"); 
        let range_2 = (split_range_2.next().unwrap().parse::<i32>().unwrap(), split_range_2.next().unwrap().parse::<i32>().unwrap());

        if (range_1.0 <= range_2.0 && range_1.1 >= range_2.1)
        || (range_2.0 <= range_1.0 && range_2.1 >= range_1.1)
        {
            sum += 1;
        }

    }
    sum
}

fn part_two(pairs: &Vec<&str>) -> i32 { 
    let mut sum: i32 = 0;
    for pair in pairs {
        let mut split = pair.split(",");
        let pair_tuple = (split.next().unwrap(), split.next().unwrap());

        let mut split_range_1 = pair_tuple.0.split("-"); 
        let range_1 = (split_range_1.next().unwrap().parse::<i32>().unwrap(), split_range_1.next().unwrap().parse::<i32>().unwrap());
        
        let mut split_range_2 = pair_tuple.1.split("-"); 
        let range_2 = (split_range_2.next().unwrap().parse::<i32>().unwrap(), split_range_2.next().unwrap().parse::<i32>().unwrap());

        if (range_1.0 <= range_2.0 && range_1.1 >= range_2.1)
        || (range_2.0 <= range_1.0 && range_2.1 >= range_1.1)
        || (range_1.0 >= range_2.0 && range_1.0 <= range_2.1)
        || (range_1.1 >= range_2.0 && range_1.1 <= range_2.1)
        {
            sum += 1;
        }
    }
    sum
}