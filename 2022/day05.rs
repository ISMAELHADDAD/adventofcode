use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let file_path = args[1].clone();

    let contents = fs::read_to_string(file_path)
        .expect("Couldn't read file");

    let moves: Vec<&str> = contents.split("\n").collect();

    let result_part_one: String = part_one(&moves);
    println!("part one: {}", result_part_one);

    let result_part_two: String = part_two(&moves);
    println!("part two: {}", result_part_two);
}

fn part_one(moves: &Vec<&str>) -> String { 
    let stack_1 = Vec::from(["F", "D", "B", "Z", "T", "J", "R", "N"]);
    let stack_2 = Vec::from(["R", "S", "N", "J", "H"]);
    let stack_3 = Vec::from(["C", "R", "N", "J", "G", "Z", "F", "Q"]);
    let stack_4 = Vec::from(["F", "V", "N", "G", "R", "T", "Q"]);
    let stack_5 = Vec::from(["L", "T", "Q", "F"]);
    let stack_6 = Vec::from(["Q", "C", "W", "Z", "B", "R", "G", "N"]);
    let stack_7 = Vec::from(["F", "C", "L", "S", "N", "H", "M"]);
    let stack_8 = Vec::from(["D", "N", "Q", "M", "T", "J"]);
    let stack_9 = Vec::from(["P", "G", "S"]);
    let mut stacks = Vec::from([stack_1, stack_2, stack_3, stack_4, stack_5, stack_6, stack_7, stack_8, stack_9]);
    
    for move_op in moves {
        let tokens: Vec<&str> = move_op.split(" ").collect();
        let move_qty = tokens[1].clone().parse::<i32>().unwrap();
        let move_from = tokens[3].clone().parse::<usize>().unwrap();
        let move_to = tokens[5].clone().parse::<usize>().unwrap();

        for _ in 0..move_qty {
            let r = stacks[move_from-1].pop().unwrap();
            stacks[move_to-1].push(r);
        }
    }
    let mut result: String = String::new();
    for stack in stacks {
        result.push_str(stack[stack.len() - 1]);
    }
    result
}

fn part_two(moves: &Vec<&str>) -> String { 
    let stack_1 = Vec::from(["F", "D", "B", "Z", "T", "J", "R", "N"]);
    let stack_2 = Vec::from(["R", "S", "N", "J", "H"]);
    let stack_3 = Vec::from(["C", "R", "N", "J", "G", "Z", "F", "Q"]);
    let stack_4 = Vec::from(["F", "V", "N", "G", "R", "T", "Q"]);
    let stack_5 = Vec::from(["L", "T", "Q", "F"]);
    let stack_6 = Vec::from(["Q", "C", "W", "Z", "B", "R", "G", "N"]);
    let stack_7 = Vec::from(["F", "C", "L", "S", "N", "H", "M"]);
    let stack_8 = Vec::from(["D", "N", "Q", "M", "T", "J"]);
    let stack_9 = Vec::from(["P", "G", "S"]);
    let mut stacks = Vec::from([stack_1, stack_2, stack_3, stack_4, stack_5, stack_6, stack_7, stack_8, stack_9]);
    
    for move_op in moves {
        let tokens: Vec<&str> = move_op.split(" ").collect();
        let move_qty = tokens[1].clone().parse::<i32>().unwrap();
        let move_from = tokens[3].clone().parse::<usize>().unwrap();
        let move_to = tokens[5].clone().parse::<usize>().unwrap();

        let mut crates_to_move: Vec<&str> = Vec::<&str>::new();
        for _ in 0..move_qty {
            let r = stacks[move_from-1].pop().unwrap();
            crates_to_move.push(r);
        }
        for _ in 0..move_qty {
            let r = crates_to_move.pop().unwrap();
            stacks[move_to-1].push(r);
        }
    }
    let mut result: String = String::new();
    for stack in stacks {
        result.push_str(stack[stack.len() - 1]);
    }
    result
}