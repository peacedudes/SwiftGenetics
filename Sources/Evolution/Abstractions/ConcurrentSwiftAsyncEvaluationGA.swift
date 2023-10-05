//
//  ConncurrentSwiftAsyncEvaluationGA.swift
//
//
//  Created by robert on 10/2/23.
//
// This version uses Swift's async/await
// Cloned and modified version of:
//
//  ConcurrentSynchronousEvaluationGA.swift
//  SwiftGenetics
//
//  Created by Santiago Gonzalez on 6/12/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

#if os(OSX) || os(iOS) // Linux does not have Dispatch
// TODO: test out on Linux.

/// Encapsulates a generic genetic algorithm that performs synchronous fitness
/// evaluations concurrently. The fitness evaluator needs to be thread-safe.
final public class ConcurrenSwiftAsyncEvaluationGA<Eval: SwiftAsyncFitnessEvaluator, LogDelegate: EvolutionLoggingDelegate> : EvolutionWrapper where Eval.G == LogDelegate.G {
  
    public var fitnessEvaluator: Eval
    public var afterEachEpochFns = [(Int) -> ()]()

    /// A delegate for logging information from the GA.
    var loggingDelegate: LogDelegate

    /// Creates a new evolution wrapper.
    public init(fitnessEvaluator: Eval, loggingDelegate: LogDelegate) {
        self.fitnessEvaluator = fitnessEvaluator
        self.loggingDelegate = loggingDelegate
    }

    public func evolve(population: Population<Eval.G>, configuration: EvolutionAlgorithmConfiguration) async {
        for i in 0..<configuration.maxEpochs {
            // Log start of epoch.
            loggingDelegate.evolutionStartingEpoch(i)
            let startDate = Date()

            // Perform an epoch.
            population.epoch()

            // Calculate fitnesses concurrently.
            
            if #available(macOS 10.15, *) {
                await withTaskGroup(of: Void.self) { taskGroup in
                    for organism in population.organisms {
                        guard organism.fitness == nil else { continue }
                        taskGroup.addTask {
                            //                    let fitnessResult =
                            organism.fitness = await self.fitnessEvaluator.fitnessFor(organism: organism, solutionCallback: { solution, fitness in
                                self.loggingDelegate.evolutionFoundSolution(solution, fitness: fitness)
                            }).fitness
                            //                    return (organism, fitnessResult)
                        }
                    }
                    for await _ in taskGroup {
                        //                    result.organism.fitness = result.fitness.fitnessResult.fitness
                        
                    }
                }
            } else {
                fatalError("This macOS version doesn't suport concurrency enough")
                // Fallback on earlier versions
            }

            // Print epoch statistics.
            let elapsedInterval = Date().timeIntervalSince(startDate)
            loggingDelegate.evolutionFinishedEpoch(i, duration: elapsedInterval, population: population)

            // Execute epoch finished functions.
            for fn in afterEachEpochFns {
                fn(i)
            }
        }

    }

}

#endif
