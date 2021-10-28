//
//  Promise.swift
//  asycEmurate
//
//  Created by yuki on 2021/08/07.
//

public final class Promise<Output, Failure: Error> {
    public enum State {
        case pending
        case fulfilled(Output)
        case rejected(Failure)
    }
    
    struct Subscriber {
        public let resolve: (Output) -> ()
        public let reject: (Failure) -> ()
    }

    public private(set) var state = State.pending
    var subscribers = [Subscriber]()
    
    public init() {}
    
    public func fullfill(_ output: Output) {
        guard case .pending = self.state else { return }
        
        self.state = .fulfilled(output)
        for subscriber in self.subscribers { subscriber.resolve(output) }
        self.subscribers.removeAll()
    }
    
    public func reject(_ failure: Failure) {
        guard case .pending = self.state else { return }
        
        self.state = .rejected(failure)
        for subscriber in self.subscribers { subscriber.reject(failure) }
        self.subscribers.removeAll()
    }

    func subscribe(_ resolve: @escaping (Output) -> (), _ reject: @escaping (Failure) -> ()) {
        switch self.state {
        case .pending: self.subscribers.append(Subscriber(resolve: resolve, reject: reject))
        case .fulfilled(let output): resolve(output)
        case .rejected(let failure): reject(failure)
        }
    }
}

extension Promise: CustomStringConvertible {
    public var description: String { "Promise<\(Output.self), \(Failure.self)>(\(self.state))" }
}
