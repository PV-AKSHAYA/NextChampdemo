package com.example.NextChamp

// Import generated UserApi and UserDetails classes from Pigeon-generated code
import com.example.NextChamp.UserApi
import com.example.NextChamp.UserDetails

// Implementation of UserApi interface
class UserApiImpl : UserApi {
    // Implement the registerUser method defined by Pigeon
    override fun registerUser(details: UserDetails): UserDetails? {
        // TODO: Add your native registration logic here.
        // Currently, just returning input details to confirm communication.
        return UserDetails(
            name = details.name,
            gender = details.gender,
            mobile = details.mobile,
            email = details.email
        )
    }
}
