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
	var id = UUID()
	public typealias RealGene = LivingTradeGene<GeneType>
	
	/// The trade's root gene.
	public var rootGene: RealGene
	
	/// Creates a new genome with the given tree root.
	public init(rootGene: RealGene) {
		self.rootGene = rootGene
	}
	
	mutating public func mutate(rate: Double, environment: Environment) {
		rootGene.bottomUpEnumerate { gene in
//            try? LivingTradeGenome.verifyIntegrity(gene: gene, isRoot: false)
			gene.mutate(rate: rate, environment: environment)
//            try? LivingTradeGenome.verifyIntegrity(gene: gene, isRoot: false)
		}
	}
	
    // TODO: this not gonna work without some thought
    public func crossover(with partner: LivingTradeGenome, rate: Double, environment: Environment) -> (LivingTradeGenome, LivingTradeGenome) {
        //return(self, partner)
        guard Double.fastRandomUniform() < rate else { return (self, partner) }
        guard partner.rootGene.children.count > 1 && self.rootGene.children.count > 1 else { return (self, partner) }
        
        var childRootA = rootGene.copy()
        var childRootB = partner.rootGene.copy()
        
        var crossoverRootA = childRootA.allNodes.filter({ !$0.geneType.isTopLevel }).randomElement()!
        var crossoverRootB = childRootB.allNodes.filter({ !$0.geneType.isTopLevel }).randomElement()!
        
        // insure both chosen genes are numeric, or both are boolean
        // if they don't match, choose the nearest boolean ansestor of the numeric gene
        if crossoverRootA.geneType.hasBooleanResult != crossoverRootB.geneType.hasBooleanResult {
            while !crossoverRootA.geneType.hasBooleanResult { crossoverRootA = crossoverRootA.parent! }
            while !crossoverRootB.geneType.hasBooleanResult { crossoverRootB = crossoverRootB.parent! }
        }
        
        let crossoverRootAOriginalParent = crossoverRootA.parent
        let crossoverRootBOriginalParent = crossoverRootB.parent
        
        crossoverRootA.parent = crossoverRootBOriginalParent
        crossoverRootB.parent = crossoverRootAOriginalParent
        
        // Crossover to create first child.
        if let parent = crossoverRootBOriginalParent {
            let i = parent.children.firstIndex { $0.parent !== parent }!
            parent.children[i] = crossoverRootA
        }
//        else { fatalError() }
//        try? Self.verifyIntegrity(gene: childRootB, isRoot: true)

        // Crossover to create second child.
        if let parent = crossoverRootAOriginalParent {
            let i = parent.children.firstIndex { $0.parent !== parent }!
            parent.children[i] = crossoverRootB
        }
//        else { fatalError() }
//        try? Self.verifyIntegrity(gene: childRootA, isRoot: true)

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

extension LivingTradeGenome: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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



extension LivingTradeGenome {
    
    enum GeneError: Error, LocalizedError {
        case integrity(String)
        
        public var errorDescription: String? {
            switch self {
            case .integrity(let string): "Integrity Error: \(string)"
            }
        }
    }
    
    public static func verifyIntegrity(gene: RealGene, isRoot: Bool = false) throws {
        do {
            if isRoot {
                if !gene.geneType.isTopLevel {
                    throw GeneError.integrity("The root gene must be long/short \(gene.geneType)")
                }
                if gene.parent != nil {
                    throw GeneError.integrity("The root gene's parent is not nil")
                }
            }
            
            let children = gene.children
            if children.count != gene.geneType.childCount {
                throw GeneError.integrity("'\(gene.geneType.name)'expected \(gene.geneType.childCount) children, found \(children.count)")
            }
            for child in children {
                if child.parent != gene {
                    throw GeneError.integrity("'\(gene.geneType.name)' has a child with the wrong parent")
                }
            }

            for child in children {
                if gene.geneType.needsBooleanResult {
                    if !child.geneType.hasBooleanResult {
                        throw GeneError.integrity("'\(gene.geneType.name)' requires a bool, has \(child.geneType.name)")
                    }
                } else if child.geneType.hasBooleanResult {
                    throw GeneError.integrity("'\(gene.geneType.name)' requires a number, has \(child.geneType.name)")
                }
            }
            for child in children {
                try verifyIntegrity(gene: child, isRoot: false)
            }
            
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
}
