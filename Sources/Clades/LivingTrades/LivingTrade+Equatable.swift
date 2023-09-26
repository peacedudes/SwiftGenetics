//
//  LivingTrade+Equatable.swift
//  SwiftGenetics
//
//  Created by Santiago Gonzalez on 6/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

extension LivingTradeGene: Equatable {
	
	// NOTE: does not compare parents.
	public static func == (lhs: LivingTradeGene, rhs: LivingTradeGene) -> Bool {
		return
			lhs.coefficient == rhs.coefficient &&
			lhs.allowsCoefficient == rhs.allowsCoefficient &&
			lhs.geneType == rhs.geneType &&
			lhs.children == rhs.children
	}
	
}
