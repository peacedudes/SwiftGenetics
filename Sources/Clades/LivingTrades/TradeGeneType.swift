//
//  TradeGeneType.swift
//  SwiftGenetics
//
//  Created by Santiago Gonzalez on 6/27/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

/// An abstract interface that all trade gene types conform to.
public protocol TradeGeneType: Hashable, Codable {
    var isTopLevel: Bool { get }
	var childCount: Int { get }
	var isBinaryType: Bool { get }
	var isUnaryType: Bool { get }
	var isLeafType: Bool { get }
    var isNumericConstant: Bool { get }
    var hasBooleanResult: Bool { get }
    var name: String { get } // debugging aid
    var needsBooleanResult: Bool { get }
    
	static var binaryTypes: [Self] { get }
	static var unaryTypes: [Self] { get }
	static var leafTypes: [Self] { get }
	static var nonLeafTypes: [Self] { get }
	static var allTypes: [Self] { get }
    
    static func compatibleAlternate(to: Self) -> Self
//    static var template: TradeGeneTemplate<Self> { get }
    static func genePool(for parent: Self?) -> [Self]
}

extension TradeGeneType {
//	public var isBinaryType: Bool { return Self.binaryTypes.contains(self) }
//	public var isUnaryType: Bool { return Self.unaryTypes.contains(self) }
//	public var isLeafType: Bool { return Self.leafTypes.contains(self) }
	
	public static var nonLeafTypes: [Self] { return binaryTypes + unaryTypes }
	public static var allTypes: [Self] { return nonLeafTypes + leafTypes }
}

/*
/// Templates can enforce certain constraints and define gene type sampling.
public struct TradeGeneTemplate<T: TradeGeneType>: Codable {
	/// Sampling array for binary gene types.
	let binaryTypes: [T]
	/// Sampling array for unary gene types.
	let unaryTypes: [T]
	/// Sampling array for leaf gene types.
	let leafTypes: [T]
	
	/// A sampling array for non-leaf types.
	var nonLeafTypes: [T] { return binaryTypes + unaryTypes }
	/// A sampling array for all types.
	var allTypes: [T] { return nonLeafTypes + leafTypes }
	
	/// Creates a new template.
	public init(binaryTypes: [T], unaryTypes: [T], leafTypes: [T]) {
		self.binaryTypes = binaryTypes
		self.unaryTypes = unaryTypes
		self.leafTypes = leafTypes
	}
}
extension TradeGeneTemplate: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(binaryTypes)
		hasher.combine(unaryTypes)
		hasher.combine(leafTypes)
	}
}
 */
