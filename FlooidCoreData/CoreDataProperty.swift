//
//  CoreDataProperty.swift
//  DandaniaCoreData
//
//  Created by Martin Lalev on 07/07/2021.
//  Copyright © 2021 Martin Lalev. All rights reserved.
//

import CoreData

@dynamicMemberLookup
public class ProxyContainer<V> {
    let wrapped: V
    public init(_ wrapped: V) {
        self.wrapped = wrapped
    }
    public subscript<T: Equatable>(dynamicMember keyPath: ReferenceWritableKeyPath<V, T>) -> T {
        get {
            self.wrapped[keyPath: keyPath]
        }
        set {
            guard self.wrapped[keyPath: keyPath] != newValue else { return }
            self.wrapped[keyPath: keyPath] = newValue
        }
    }
}

open class CoreDataObjectProxy<Object: PlainCoreDataObject> {
    public let object: Object
    public required init(_ object: Object) { self.object = object }
}


@propertyWrapper
public struct CoreDataProperty<Object: PlainCoreDataObject, EnclosingType: CoreDataObjectProxy<Object>, Value: Equatable, MappedValue: Equatable> {

    public static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingType, MappedValue>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> MappedValue {
        get {
            let property = instance[keyPath: storageKeyPath]
            switch property.path {
            case let .standard(keyPath, mapRead, _):
                return mapRead(instance[keyPath: keyPath])
            case let .optional(keyPath, defaultValue, mapRead, _):
                return mapRead(instance[keyPath: keyPath] ?? defaultValue)
            }
        }
        set {
            let property = instance[keyPath: storageKeyPath]
            switch property.path {
            case let .standard(keyPath, _, mapWrite):
                guard instance[keyPath: keyPath] != mapWrite(newValue) else { return }
                instance[keyPath: keyPath] = mapWrite(newValue)
            case let .optional(keyPath, defaultValue, _, mapWrite):
                guard instance[keyPath: keyPath] ?? defaultValue != mapWrite(newValue) else { return }
                instance[keyPath: keyPath] = mapWrite(newValue)
            }
        }
    }

    @available(*, unavailable, message: "@CoreDataProperty can only be applied to classes")
    public var wrappedValue: MappedValue {
        get { fatalError() }
        set { fatalError() }
    }

    private let path: Path
    enum Path {
        case standard(ReferenceWritableKeyPath<EnclosingType, Value>, (Value) -> MappedValue, (MappedValue) -> Value)
        case optional(ReferenceWritableKeyPath<EnclosingType, Value?>, Value, (Value) -> MappedValue, (MappedValue) -> Value)
    }

    public init(_ keyPath: ReferenceWritableKeyPath<EnclosingType, Value>, _ mapRead: @escaping (Value) -> MappedValue, _ mapWrite: @escaping (MappedValue) -> Value) {
        self.path = .standard(keyPath, mapRead, mapWrite)
    }
    public init(_ keyPath: ReferenceWritableKeyPath<EnclosingType, Value?>, _ defaultValue: Value, _ mapRead: @escaping (Value) -> MappedValue, _ mapWrite: @escaping (MappedValue) -> Value) {
        self.path = .optional(keyPath, defaultValue, mapRead, mapWrite)
    }
}

public extension CoreDataProperty where Value == MappedValue {
    init(_ keyPath: ReferenceWritableKeyPath<EnclosingType, Value>) {
        self.init(keyPath, { $0 }, { $0 })
    }
    init(_ keyPath: ReferenceWritableKeyPath<EnclosingType, Value?>, _ defaultValue: Value) {
        self.init(keyPath, defaultValue, { $0 }, { $0 })
    }
}

public extension CoreDataProperty where Value == Int16, MappedValue == Int {
    init(_ keyPath: ReferenceWritableKeyPath<EnclosingType, Int16>) {
        self.init(keyPath, Int.init, Int16.init)
    }
    init(_ keyPath: ReferenceWritableKeyPath<EnclosingType, Int16?>, _ defaultValue: Int16) {
        self.init(keyPath, defaultValue, Int.init, Int16.init)
    }
}

public extension CoreDataContext {
    func replace<O: AnyObject, Value: PlainCoreDataObject>(_ object: O, keyPath: ReferenceWritableKeyPath<O,Value?>, newValue: Value?) {
        if object[keyPath: keyPath] != newValue {
            object[keyPath: keyPath]?.delete(from: self)
            object[keyPath: keyPath] = newValue
        }
    }
}

