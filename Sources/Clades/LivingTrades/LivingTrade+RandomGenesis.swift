//
//  LivingTrade+RandomGenesis.swift
//  SwiftGenetics
//
//  Created by Santiago Gonzalez on 6/27/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

extension LivingTradeGene {
	
	/// Returns a random, recursively built trade subject to certain constraints.
	public static func random(onlyNonLeaf: Bool = false, depth: Int = 1, parent: LivingTradeGene? = nil, template: TradeGeneTemplate<GeneType>) -> LivingTradeGene {
		let randomType = onlyNonLeaf ? template.nonLeafTypes.randomElement()! : template.allTypes.randomElement()!
		let gene = LivingTradeGene(template, geneType: randomType, parent: parent, children: [])
		if randomType.isBinaryType {
			if depth == 1 {
				gene.children = [
					LivingTradeGene(template, geneType: template.leafTypes.randomElement()!, parent: gene, children: []),
					LivingTradeGene(template, geneType: template.leafTypes.randomElement()!, parent: gene, children: [])
				]
			} else {
				gene.children = [
					random(onlyNonLeaf: onlyNonLeaf, depth: depth - 1, parent: gene, template: template),
					random(onlyNonLeaf: onlyNonLeaf, depth: depth - 1, parent: gene, template: template)
				]
			}
		} else if randomType.isUnaryType {
			gene.children = [LivingTradeGene(template, geneType: template.leafTypes.randomElement()!, parent: gene, children: [])]
		} else if randomType.isLeafType {
			// nop
		} else {
			fatalError()
		}
		return gene
	}
}
