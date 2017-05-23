//
//  BasicOperatorSpec.swift
//  RealmTxn
//
//  Created by ukitaka on 2017/05/22.
//  Copyright © 2017年 waft. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
import RealmTxn

class BasicOperatorSpec: QuickSpec {
    let realm = try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "for test"))

    override func spec() {
        super.spec()

        describe("`map` operator") {
            beforeEach {
                try! self.realm.write {
                    self.realm.deleteAll()
                    self.realm.add(Dog.dogs)
                }
            }

            it("works well with `map` operator") {
                let txn = Realm.TxnOps
                    .object(ofType: Dog.self, forPrimaryKey: "A")
                    .map { $0?.name ?? "" }
                let result = try! self.realm.run(txn: txn)

                expect(txn).to(beAnInstanceOf(RealmReadTxn<String>.self))
                expect(result).to(equal("A"))
            }

            it("does not affect Read / Write type parameter") {
                let readTxn = RealmReadTxn<Void> { _ in }
                let writeTxn = RealmWriteTxn<Void> { _ in }

               expect(readTxn.map(id).isRead).to(beTrue())
               expect(writeTxn.map(id).isWrite).to(beTrue())
            }
        }

        describe("`ask` operator") {
            it("works well with `ask` operator") {
                let txn = (RealmReadTxn<Void> { _ in }).ask()
                expect(txn).to(beAnInstanceOf(RealmReadTxn<Realm>.self))
                expect(try! self.realm.run(txn: txn)).to(be(self.realm))
            }

            it("does not affect Read / Write type parameter") {
                let readTxn = RealmReadTxn<Void> { _ in }
                let writeTxn = RealmWriteTxn<Void> { _ in }

                expect(readTxn.ask().isRead).to(beTrue())
                expect(writeTxn.ask().isWrite).to(beTrue())
            }
        }

        describe("`flatMap` operator") {
            beforeEach {
                try! self.realm.write {
                    self.realm.deleteAll()
                    self.realm.add(Dog.dogs)
                }
            }

            it("works well with `flatMap` operator") {
                let readDogATxn = RealmReadTxn<Dog>.object(forPrimaryKey: "A").map { $0! }
                
                func modifyDogAgeTxn(dog: Dog) -> RealmWriteTxn<Dog> {
                    return RealmWriteTxn<Dog> { realm in
                        dog.age = 18
                        return dog
                    }
                }

                let txn = readDogATxn
                    .flatMap(modifyDogAgeTxn)
                    .map { $0.age }
                
                expect(try! self.realm.run(txn: txn)).to(equal(18))
            }
        }

        describe("`writeTxn` operator") {
            it("works well with `writeTxn` operator") {
                let readTxn = RealmReadTxn<Void> { _ in }
                expect(readTxn.writeTxn).to(beAnInstanceOf(RealmWriteTxn<Void>.self))
            }
        }
    }
}
