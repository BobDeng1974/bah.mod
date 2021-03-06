' Copyright (c) 2010 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
' 
SuperStrict

Rem
bbdoc: Keychain Services
End Rem
Module BaH.Keychain

ModuleInfo "Version: 1.00"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: 2010 Bruce A Henderson"

ModuleInfo "History: 1.00 Initial Release"



?macos

Import "common.bmx"

Rem
bbdoc: Contains information about a keychain.
End Rem
Type TKeychain

	Field kcPtr:Byte Ptr
	
	Global errStatus:Int
	
	Rem
	bbdoc: Opens a Keychain for the given @path.
	about: If path is empty, the default keychain will be opened.
	End Rem
	Method Open:TKeychain(path:String = Null)
		If path Then
			kcPtr = bmx_keychain_open(path)
		Else
			kcPtr = bmx_keychain_open(Null)
		End If
		
		If kcPtr Then
			Return Self
		End If
	End Method
	
	Rem
	bbdoc: Creates an empty keychain.
	about: If user interaction to create a keychain is posted, the newly-created keychain is automatically unlocked after creation.
	<p>
	The system ensures that a default keychain is created for the user at login, thus, in most cases, you do not need to call this function
	yourself. Users can create additional keychains, or change the default, by using the Keychain Access application. However, a missing
	default keychain is not recreated automatically, and you may receive an errSecNoDefaultKeychain error from other functions if a
	default keychain does not exist. In that case, you can use this function followed by #SetDefault, to create a new default keychain.
	You can also call this function to create a private temporary keychain for your application’s use, in cases where no user interaction can occur.
	</p>
	End Rem
	Function Create:TKeychain(path:String, password:String, promptUser:Int = False)
		Local this:TKeychain = New TKeychain
		
		this.kcPtr = bmx_keychain_create(path, password, promptUser)
		
		If Not this.kcPtr Then
			Return Null
		End If
		
		Return this
	End Function
	
	Method Delete()
		If kcPtr Then
			bmx_keychain_free(kcPtr)
			kcPtr = Null
		End If
	End Method

	Rem
	bbdoc: Returns a string explaining the meaning of a security result code
	End Rem
	Function ErrorMessage:String(status:Int)
		Return bmx_keychain_SecCopyErrorMessageString(status)
	End Function
	
	Rem
	bbdoc: Returns the last error status code.
	End Rem
	Function LastError:Int()
		Return errStatus
	End Function
	
	Function _postLastError(error:Int)
		errStatus = error
	End Function
	
	Rem
	bbdoc: Enables or disables the user interface for Keychain Services functions that automatically display a user interface.
	about: Certain Keychain Services functions that require the presence of a keychain automatically display a Keychain Not Found
	dialog if there is none. Functions that require the keychain to be unlocked automatically display the Unlock Keychain dialog.
	The #SetUserInteractionAllowed function enables you to control whether these functions display a user interface. By
	default, user interaction is permitted.
	<p>
	If you are writing an application that must run unattended on a server, you may wish to disable the user interface
	so that any subsequent keychain calls that normally bring up the unlock UI will instead return immediately with an
	#errSecInteractionRequired result). In this case you must programmatically create a keychain or unlock the keychain when necessary.
	</p>
	<p>
	<b>Note: </b> If you disable user interaction before calling a Keychain Services function, be sure to reenable it when you are
	finished. Failure to reenable user interaction will affect other clients of the Keychain Services.
	</p>
	End Rem
	Function SetUserInteractionAllowed(allowed:Int)
		bmx_keychain_SecKeychainSetUserInteractionAllowed(allowed)
	End Function
	
	Rem
	bbdoc: Indicates whether Keychain Services functions that normally display a user interaction are allowed to do so.
	End Rem
	Function IsUserInteractionAllowed:Int()
		Return bmx_keychain_SecKeychainGetUserInteractionAllowed()
	End Function
	
	Rem
	bbdoc: Finds the first Internet password based on the attributes passed
	about: This method finds the first Internet password item that matches the attributes you provide.
	<p>
	It decrypts the password before returning it to you. If the calling application is not in the list of trusted applications,
	the user is prompted before access is allowed. If the access controls for this item do not allow decryption, the function
	will raise an errSecAuthFailed error.
	</p>
	<p>
	The method automatically calls the method #Unlock to display the Unlock Keychain dialog box if the keychain is currently locked.
	</p>
	End Rem
	Method FindInternetPassword:String(protocol:Int, serverName:String, accountName:String, path:String, authenticationType:Int, securityDomain:String = Null, port:Int = 0, item:TKeychainItem = Null)

		If item Then
			If securityDomain Then
				Return bmx_keychain_SecKeychainFindInternetPassword(kcPtr, protocol, serverName, accountName, path, authenticationType, securityDomain, port, item.kcPtr)
			Else
				Return bmx_keychain_SecKeychainFindInternetPassword(kcPtr, protocol, serverName, accountName, path, authenticationType, Null, port, item.kcPtr)
			End If
		Else
			If securityDomain Then
				Return bmx_keychain_SecKeychainFindInternetPassword(kcPtr, protocol, serverName, accountName, path, authenticationType, securityDomain, port, Null)
			Else
				Return bmx_keychain_SecKeychainFindInternetPassword(kcPtr, protocol, serverName, accountName, path, authenticationType, Null, port, Null)
			End If
		End If
	End Method
	
	Rem
	bbdoc: Adds a new Internet password to a keychain.
	End Rem
	Method AddInternetPassword(password:String, protocol:Int, serverName:String, accountName:String, path:String, authenticationType:Int, securityDomain:String = Null, port:Int = 0, item:TKeychainItem = Null)
		If item Then
			If securityDomain Then
				bmx_keychain_SecKeychainAddInternetPassword(kcPtr, password, protocol, serverName, accountName, path, authenticationType, securityDomain, port, item.kcPtr)
			Else
				bmx_keychain_SecKeychainAddInternetPassword(kcPtr, password, protocol, serverName, accountName, path, authenticationType, Null, port, item.kcPtr)
			End If
		Else
			If securityDomain Then
				bmx_keychain_SecKeychainAddInternetPassword(kcPtr, password, protocol, serverName, accountName, path, authenticationType, securityDomain, port, Null)
			Else
				bmx_keychain_SecKeychainAddInternetPassword(kcPtr, password, protocol, serverName, accountName, path, authenticationType, Null, port, Null)
			End If
		End If
	End Method

	Rem
	bbdoc: Finds the first generic password based on the attributes passed.
	End Rem
	Method FindGenericPassword:String(serviceName:String, accountName:String, item:TKeychainItem = Null)
		If item Then
			Return bmx_keychain_SecKeychainFindGenericPassword(kcPtr, serviceName, accountName, item.kcPtr)
		Else
			Return bmx_keychain_SecKeychainFindGenericPassword(kcPtr, serviceName, accountName, Null)
		End If
	End Method

	Rem
	bbdoc: Adds a new generic password to the keychain.
	about: Required parameters to identify the password are @serviceName and @accountName, which are application-defined strings.
	This method optionally returns a reference to the newly added @item.
	<p>
	You can use this function to add passwords for accounts other than the Internet. For example, you might add AppleShare passwords, or passwords for your database or scheduling programs.
	</p>
	<p>
	This method sets the initial access rights for the new keychain item so that the application creating the item is given trusted access.
	</p>
	<p>
	It automatically calls the method #Unlock to display the Unlock Keychain dialog box if the keychain is currently locked.
	</p>
	<p>
	End Rem
	Method AddGenericPassword(password:String, serviceName:String, accountName:String, item:TKeychainItem = Null)
		If item Then
			bmx_keychain_SecKeychainAddGenericPassword(kcPtr, password, serviceName, accountName, item.kcPtr)
		Else
			bmx_keychain_SecKeychainAddGenericPassword(kcPtr, password, serviceName, accountName, Null)
		End If
	End Method
	
	Rem
	bbdoc: Unlocks a keychain.
	about: In most cases, your application does not need to call this method directly, since most Keychain Services functions
	that require an unlocked keychain do so for you. If your application needs to verify that a keychain is unlocked,
	call the method #GetStatus.
	End Rem
	Method Unlock(password:String = Null, usePassword:Int = False)
		If password Then
			bmx_keychain_SecKeychainUnlock(kcPtr, password, usePassword)
		Else
			bmx_keychain_SecKeychainUnlock(kcPtr, Null, usePassword)
		End If
	End Method
	
	Rem
	bbdoc: Sets the default keychain.
	about: In most cases, your application should not need to set the default keychain, because this is a choice normally made by
	the user. You may call this method to change where a password or other keychain items are added, but since this is a user choice,
	you should set the default keychain back to the user specified keychain when you are done.
	End Rem
	Method SetDefault()
		bmx_keychain_SecKeychainSetDefault(kcPtr)
	End Method
	
	Rem
	bbdoc: Retrieves status information of the keychain.
	returns: A mask containing one or more of kSecUnlockStateStatus, kSecReadPermStatus and kSecWritePermStatus.
	about: You can use this method to determine if the keychain is unlocked, readable, or writable. Note that the lock status
	of a keychain can change at any time due to user or system activity. Because the system automatically prompts the user to
	unlock a keychain when necessary, you do not usually have to worry about the lock status of a keychain.
	End Rem
	Method GetStatus:Int()
		Return bmx_keychain_SecKeychainGetStatus(kcPtr)
	End Method
	
	Rem
	bbdoc: Determines the path of a keychain.
	End Rem
	Method GetPath:String()
		Return bmx_keychain_SecKeychainGetPath(kcPtr)
	End Method

	Rem
	bbdoc: Removes the keychain from the default keychain search list, and removes the keychain itself if it is a file.
	about: The keychain may be a file stored locally, a smart card, or retrieved from a network server using non-file-based
	database protocols. This method deletes the keychain only if it is a local file.
	End Rem
	Method Remove()
		bmx_keychain_SecKeychainDelete(kcPtr)
	End Method
	
End Type

Rem
bbdoc: Contains information about a keychain item.
End Rem
Type TKeychainItem

	Field kcPtr:Byte Ptr

	Method New()
		kcPtr = bmx_keychainitem_create()
	End Method
	
	Rem
	bbdoc: Updates the keychain item.
	about: The keychain item is written to the keychain’s permanent data store. If the keychain item has not previously been
	added to a keychain, a call to this method does nothing and results in a status of #noErr.
	End Rem
	Method ModifyPassword(password:String)
		bmx_keychainitem_SecKeychainItemModifyAttributesAndData(kcPtr, password)
	End Method
	
	Rem
	bbdoc: Deletes a keychain item from the default keychain's permanent data store.
	about: If the keychain item has not previously been added to the keychain, this method does nothing and sets a status of #noErr.
	Do not delete a keychain item and recreate it in order to modify it; instead, use the #ModifyPassword to modify the existing keychain item.
	When you delete a keychain item, you lose any access controls and trust settings added by the user or by other applications.
	End Rem
	Method Remove()
		bmx_keychainitem_SecKeychainItemDelete(kcPtr)
	End Method
	
	Method Delete()
		If kcPtr Then
			bmx_keychainitem_free(kcPtr)
			kcPtr = Null
		End If
	End Method

End Type



?
