//
//  LivingTradeGene.swift
//  SwiftGenetics
//
//  Created by Santiago Gonzalez on 11/15/18.
//  Copyright © 2018 Santiago Gonzalez. All rights reserved.
//

import Foundation

/// An element in a genetic trade, which can recursively contain a subtree of tree genes.
final public class LivingTradeGene<GeneType: TradeGeneType>: Gene {
	public typealias Environment = LivingTradeEnvironment
	
	/// The sampling template that's used for the gene types.
//	public var template: TradeGeneTemplate<GeneType>
	
	/// The gene's type marker.
	public var geneType: GeneType
	/// A weak reference to the gene's parent gene, or `nil` if it's the root.
	public weak var parent: LivingTradeGene?
	/// Owned references to child genes.
	public var children: [LivingTradeGene]
	
	/// Creates a new trade gene.
    public init(geneType: GeneType, parent: LivingTradeGene?, children: [LivingTradeGene]) {
		self.geneType = geneType
		self.parent = parent
		self.children = children
	}
	
	public func mutate(rate: Double, environment: Environment) {
        guard parent != nil else { return }
		guard Double.fastRandomUniform() < rate else { return }
		
        // TODO: remove
        if parent == nil, !geneType.isTopLevel {
                print("bad root detected... \(geneType)")
        }

//        try? LivingTradeGenome.verifyIntegrity(gene: self, isRoot: false)
		performGeneTypeSpecificMutations(rate: rate, environment: environment)
//        try? LivingTradeGenome.verifyIntegrity(gene: self, isRoot: false)

		var madeStructuralMutation = false
		
		// Deletion mutations.
        // Replace non-leaf types with something else, hopefully shorter
		if Double.fastRandomUniform() < environment.structuralMutationDeletionRate {
            if !geneType.isLeafType, 
            parent != nil
            {
                let newGene = Self.randomGene(parent: parent, depth: 1)
//                print("Swapping: \(geneType) \nto: \(newGene.geneType)")
//                print("...Deietion mutation \(geneType.name) changed to \(newGene.geneType.name)")
                geneType = newGene.geneType // hopefully a leaf type, or at least a simpler tree
                children = newGene.children
                for child in children {
                    child.parent = self
                }
				madeStructuralMutation = true
//                try? LivingTradeGenome.verifyIntegrity(gene: parent!, isRoot: false)
			}
		}
		
		// Addition mutations.
        // Replace leaf types with something else, hopefully longer
		if Double.fastRandomUniform() < environment.structuralMutationAdditionRate {
            if geneType.isLeafType {
                let newGene = Self.randomGene(parent: parent, depth: 5)
//                print("...Addition mutation: \(geneType.name) changed to \(newGene.geneType.name)")
                geneType = newGene.geneType
                children = newGene.children
                // TODO: it seems wrong that randomGene doesn't already set this for us
                for child in children {
                    child.parent = self
                }
				madeStructuralMutation = true
//                try? LivingTradeGenome.verifyIntegrity(gene: parent!, isRoot: false)
			}
		}
		
		// Attempt to mutate type, maintaining the same structure, only if a
		// structural mutation has not already been made.
		if !madeStructuralMutation {
//            if parent == nil {
//                print("modifying parent \(geneType)")
//            }
            let newGeneType = GeneType.compatibleAlternate(to: geneType)
            if parent == nil {
                let debugString = "\(newGeneType)"
                if !debugString.contains("long") && !debugString.contains("short") {
                    print("modified parent \(geneType)\n ....to \(newGeneType)")
                }
            }
//            print("...Replacement mutation from \(geneType.name) to \(newGeneType.name)")
            geneType = newGeneType
            madeStructuralMutation = true
//            try? LivingTradeGenome.verifyIntegrity(gene: parent!, isRoot: false)

            
// TODO: Keep children, but replace gene type with compatible remplacement
//            if geneType.isBinaryType {
//				geneType = template.binaryTypes.filter { $0 != geneType }.randomElement()!
//			} else if geneType.isUnaryType {
//				geneType = template.unaryTypes.filter { $0 != geneType }.randomElement() ?? template.unaryTypes.first!
//			} else if geneType.isLeafType {
//				geneType = template.leafTypes.filter { $0 != geneType }.randomElement()!
//			} else {
//				fatalError()
//			}
		}
//        try? LivingTradeGenome.verifyIntegrity(gene: self, isRoot: false)
	}
	
	// MARK: - Enumeration, tree operations, and book-keeping.
	
	/// Performs a bottom-up, depth-first enumeration of the tree, including self.
	public func bottomUpEnumerate(eachNode fn: (LivingTradeGene) -> ()) {
		for child in children {
			child.bottomUpEnumerate(eachNode: fn)
		}
		fn(self)
	}
	
	/// Returns all nodes in the subtree, including the current gene.
	public var allNodes: [LivingTradeGene] {
		var nodes: [LivingTradeGene] = [self]
		for child in children {
			nodes.append(contentsOf: child.allNodes)
		}
		return nodes
	}
	
	/// Creates a deep copy of the gene.
	public func copy(withParent: LivingTradeGene? = nil) -> LivingTradeGene {
		let newGene = LivingTradeGene(geneType: geneType, parent: withParent, children: [])
		newGene.children = children.map { $0.copy(withParent: newGene) }
		return newGene
	}
	
	/// Rebuilds parent connections from child connections.
	public func recursivelyResetParents() {
		for child in children {
			child.parent = self
			child.recursivelyResetParents()
		}
	}
	
	// MARK: - Coding.
	
	/// Coding keys for `Codable`.
	enum CodingKeys: String, CodingKey {
//		case template
		case geneType
		case children
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(template, forKey: .template)
		try container.encode(geneType, forKey: .geneType)
		try container.encode(children, forKey: .children)
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
//		template = try values.decode(type(of: template), forKey: .template)
		geneType = try values.decode(GeneType.self, forKey: .geneType)
		children = try values.decode(type(of: children), forKey: .children)
		
		// Rebuild parent relationships.
		recursivelyResetParents()
	}
	
}

extension LivingTradeGene {
	/// Perform mutations that are specific to the living trade's `GeneType`.
	func performGeneTypeSpecificMutations(rate: Double, environment: Environment) {
		// Default implementation is intentionally empty.
	}
}


