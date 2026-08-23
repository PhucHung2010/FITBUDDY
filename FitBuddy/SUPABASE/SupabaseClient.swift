//
//  SupabaseClient.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    // TODO: Replace with your actual Supabase project URL
    let client: SupabaseClient
    
    private init() {
        let supabaseURL = URL(string: "https://wnjbzmyvrgzimbbkgczr.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InduamJ6bXl2cmd6aW1iYmtnY3pyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYyOTYxMjEsImV4cCI6MjEwMTg3MjEyMX0.VrsJL7vPjwnKf5e4yYUTy6_BuycuvaPOADIdlm3xp9Y"
        
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
