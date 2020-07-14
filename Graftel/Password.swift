//
//  ViewController.swift
//  Shorabh
//
//  Created by Shorabh on 8/10/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit
import CryptoSwift


class Password: UIViewController {
    
    @IBOutlet weak var status: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func hashValue(_ password:String) -> String
    {
        let bytesCount = 16 // number of bytes
        var salt = [UInt8](repeating: 0, count: bytesCount) // array to hold randoms bytes
        // Gen random bytes
        _ = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &salt)
        
        let password: Array<UInt8> = password.utf8.map {$0}
        let subkey = try! PKCS5.PBKDF2(password: password, salt: salt, iterations: 10000, variant: .sha256).calculate()
        
        var outputbytes = [UInt8](repeating: 0,count: 13)
        outputbytes[0] = 0x01;
        outputbytes = WriteNetworkByteOrder(outputbytes, offset: 1, value: 1);
        outputbytes = WriteNetworkByteOrder(outputbytes, offset: 5, value: 10000);
        outputbytes = WriteNetworkByteOrder(outputbytes, offset: 9, value: salt.count);
        outputbytes.append(contentsOf: salt)
        outputbytes.append(contentsOf: subkey)
        let nsdata = Data(bytes: UnsafePointer<UInt8>(outputbytes), count: outputbytes.count)
        let base64Encoded = nsdata.base64EncodedString(options: [])
        return base64Encoded
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func WriteNetworkByteOrder(_ buffer:Array<UInt8>,offset:Int,value:Int) -> Array<UInt8>
    {
        var buffer = buffer
        buffer[offset + 0] = UInt8(value >> 24);
        buffer[offset + 1] = UInt8(value >> 16);
        buffer[offset + 2] = UInt8(value >> 8);
        var x:UInt8 = 0
        var y:UInt16 = UInt16(value)
        memcpy(&x, &y, 1)
        buffer[offset + 3] = x;
        return buffer
    }
    
    
    func ReadNetworkByteOrder(_ buffer:Array<UInt8>,offset:Int) -> UInt8
    {
        var buffer = buffer
        let i = Int(buffer[offset + 0]) << 24 | Int(buffer[offset + 1]) << 16
        let j = Int(buffer[offset + 2]) << 8 | Int(buffer[offset + 3])
        return UInt8(i|j)
    }
    
    func verifyHashedValue( hashedValue:String,providedValue:String) -> Bool
    {
        if let nsdata = Data(base64Encoded: hashedValue, options: NSData.Base64DecodingOptions([])) {
            var decodedHashedPassword = [UInt8](repeating: 0, count: nsdata.count)
            (nsdata as NSData).getBytes(&decodedHashedPassword,length:nsdata.count)
            if(decodedHashedPassword[0] != 0x01)
            {
                return false;
            }
            let saltLength = ReadNetworkByteOrder(decodedHashedPassword, offset: 9);
            if (saltLength < 128/8)
            {
                return false;
            }
            var salt:Array<UInt8> = [UInt8](repeating: 0,count: Int(16))
            for i in 0 ..< salt.count {
                salt[i]=decodedHashedPassword[13+i]
            }
            let subkeyLength = decodedHashedPassword.count - 13 - salt.count;
            if (subkeyLength < 128 / 8)
            {
                return false;
            }
            var expectedSubkey:Array<UInt8> = [UInt8](repeating: 0,count: subkeyLength)
            for i in 0 ..< subkeyLength {
                expectedSubkey[i]=decodedHashedPassword[13+salt.count+i]
            }
            let actualSubkey = try! PKCS5.PBKDF2(password: providedValue.utf8.map {$0}, salt: salt, iterations: 10000, variant: .sha256).calculate()
            return expectedSubkey.toBase64() == actualSubkey.toBase64()
        }
        return false
    }
    
}

