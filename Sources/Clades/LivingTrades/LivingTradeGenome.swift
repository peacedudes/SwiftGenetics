//
//  LivingTradeGenome.swift
//  SwiftGenetics
//
//  Created by Santiago Gonzalez on 6/28/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

/// An evolvable trade.
public struct LivingTradeGenome<GeneType: TradeGeneType>: Genome {
	
	public typealias RealGene = LivingTradeGene<GeneType>
	
	/// The trade's root gene.
	public var rootGene: RealGene
	
	/// Creates a new genome with the given tree root.
	public init(rootGene: RealGene) {
		self.rootGene = rootGene
	}
	
	mutating public func mutate(rate: Double, environment: Environment) {
		rootGene.bottomUpEnumerate { gene in
			gene.mutate(rate: rate, environment: environment)
		}
	}
	
	public func crossover(with partner: LivingTradeGenome, rate: Double, environment: Environment) -> (LivingTradeGenome, LivingTradeGenome) {
		guard Double.fastRandomUniform() < rate else { return (self, partner) }
		guard partner.rootGene.children.count > 1 && self.rootGene.children.count > 1 else { return (self, partner) }
		
		var childRootA = self.rootGene.copy()
		var childRootB = partner.rootGene.copy()
		
		let crossoverRootA = childRootA.allNodes.randomElement()!
		let crossoverRootB = childRootB.allNodes.randomElement()!
		
		let crossoverRootAOriginalParent = crossoverRootA.parent
		let crossoverRootBOriginalParent = crossoverRootA.parent
		
		// Crossover to create first child.
		if let parent = crossoverRootBOriginalParent {
			crossoverRootA.parent = parent
		} else {
			childRootB = crossoverRootB
		}
		
		// Crossover to create second child.
		if let parent = crossoverRootAOriginalParent {
			crossoverRootB.parent = parent
		} else {
			childRootA = crossoverRootA
		}
		
		return (
			LivingTradeGenome(rootGene: childRootA),
			LivingTradeGenome(rootGene: childRootB)
		)
	}
	
	/// Returns a deep copy.
	public func copy() -> LivingTradeGenome {
		let newRoot = self.rootGene.copy()
		return LivingTradeGenome(rootGene: newRoot)
	}
	
}

extension LivingTradeGenome: RawRepresentable {
	public typealias RawValue = RealGene
	public var rawValue: RawValue { return rootGene }
	public init?(rawValue: RawValue) {
		self = LivingTradeGenome.init(rootGene: rawValue)
	}
}

// Living trades can behave as genes within a living forest genome.
extension LivingTradeGenome: Gene {
	public typealias Environment = RealGene.Environment
}
