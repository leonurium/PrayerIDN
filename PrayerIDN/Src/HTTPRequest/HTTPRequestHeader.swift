//
//  HTTPRequestHeader.swift
//  Pods-PrayerIDN_Example
//
//  Created by Rangga Leo on 11/01/21.
//

import Foundation

struct HTTPRequestHeader {
    enum key {
        case contentType, host, connection, contentLenght, cacheControl, accept, referer, acceptEncoding, acceptLanguage, authorization
        
        var string: String {
            get {
                switch self {
                case .accept:           return "Accept"
                case .acceptEncoding:   return "Accept-Encoding"
                case .acceptLanguage:   return "Accept-Language"
                case .cacheControl:     return "Cache-Controle"
                case .connection:       return "Connection"
                case .contentLenght:    return "Content-Lenght"
                case .contentType:      return "Content-Type"
                case .host:             return "Host"
                case .referer:          return "Referer"
                case .authorization:    return "Authorization"
                }
            }
        }
    }
}
