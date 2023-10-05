//
//  LivingTrade+RandomGenesis.swift
//  SwiftGenetics
//
//  Created by Santiago Gonzalez on 6/27/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

extension LivingTradeGene {
    /**
     Build a random gene, given certain constraints
     
     - Parameter parent: the gene's parent, or nil if it's the topLevel
     - Parameter depth: default 1; the minimum depth of tree to generate.  Nil selects a gene, but leaves children empty.
     - Parameter allowNumericConstants: default true; set to false to avoid avoid binOps with two constant children
     - Returns: new randomly created gene

     */
    /// Returns a random, recursively built tree subject to certain constraints.
    public static func randomGene(parent: LivingTradeGene? = nil,
                                  depth: Int? = 1,
                                  allowNumericConstant: Bool = true) -> LivingTradeGene
    {
        let parentGene = parent?.geneType as? GeneType
        var genePool = GeneType.genePool(for: parentGene) 
        if !allowNumericConstant {
            genePool = genePool.filter { !$0.isNumericConstant }
        }
        // prevent not not, - -, or abs(abs)
        if let parentGene, parentGene.isUnaryType {
            genePool = genePool.filter { !$0.isUnaryType }
        }

        let leafTypes = genePool.filter { $0.isLeafType }
        if depth != nil, depth! < 2 && leafTypes.count > 0 {
            genePool = leafTypes
        }

        let randomType = genePool.randomElement()!
        let gene = LivingTradeGene(geneType: randomType, parent: parent, children: [])
        guard let depth else { return gene }
        var hasConstantSibling = false
        let childCount = randomType.childCount
        for _ in 0 ..< randomType.childCount {
            let child = randomGene(parent: gene, depth: depth - 1,
                                   allowNumericConstant: !hasConstantSibling)
            gene.children.append(child)
            
            if child.parent != gene {
                print("what the actual fuck?")
            }
            if child.geneType.isNumericConstant {
                hasConstantSibling = true
            }
        }
        return gene
    }

}
