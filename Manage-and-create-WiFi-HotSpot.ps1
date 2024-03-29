<#
 Commands are found and explained at: technet.microsoft.com/en-us/library/cc755301(v=ws.10).aspx

 Author: github.com/Am0rphous

 Purpose: Help manage and create wireless networks on Windwos based computers

#>

param([string]$parameter)


function CatchErrorMessage {
    # `n gives a new line
    # `t makes a tabulator space
    # $_ shows the error message
    # 'Fore' is short for 'ForegroundColor'
    Write-Host "`t$_`n" -Fore Red
}

Function Prompt_reload_menu {
    Read-Host "`tPress 'enter' to go back"
    $menuOption = 0 #It's important to reset variable
    LoadMenu
}

Function Reload_menu_now {
    $menuOption = 0 #It's important to reset variable
    LoadMenu
}

    if ($parameter -eq "start") {
        Write-Host ""
        $menuOption = 2 # set menu option to 2 to jump to Option 2 - Start Wifi HotSpot
    } elseif ($parameter -eq "stop") {
        Write-Host ""
        $menuOption = 3 # set menu option to 3 to jump to Option 3 - Stop Wifi HotSpot
    } else {
        $menuOption = 0 # set default menu option to 0
    }


Function LoadMenu {
    
    #[int] $menuOption = 0        #Resets the menuoptions for each time the menu loads
          $t          = "`t`t"   #Each 't' makes a tab space from the left
          $nt         = "`n`t`t" #Makes a new line and two tabulator spaces
    [int] $LastOption = 10       #Total number of options in the menu
    [string] $MenuBar = "`n=========== Wifi HotSpot with PowerShell ==========="

    #Foreach option in the menu, the script checks if the user has chosen
    #a value less than 1 or an option greater than the last menu option.
    #If the value is outside this range, the code in 'default' will
    #excecute.

    while ( $menuOption -lt 1 -or $menuOption -gt $LastOption ) {
        CLS #Clears creen
        Write-Host $MenuBar                            -Fore Magenta
        Write-Host "`n`tgithub.com/Am0rphous"          -Fore Cyan
        Write-Host "$nt`Choose between these options:" -Fore Cyan
        Write-host "$nt`1. " -NoNewline -Fore Cyan; Write-Host "Configure a Wifi HotSpot"
        Write-host "$nt`2. " -NoNewline -Fore Cyan; Write-Host "Start Wifi HotSpot"
        Write-host "$nt`3. " -NoNewline -Fore Cyan; Write-Host "Stop Wifi HotSpot"
        Write-host "$nt`4. " -NoNewline -Fore Cyan; Write-Host "View hosted network settings"
        Write-host "$nt`5. " -NoNewline -Fore Cyan; Write-Host "Show Wireless LAN settings"
        Write-host "$nt`6. " -NoNewline -Fore Cyan; Write-Host "Display blocked networks"
        Write-host "$nt`7. " -NoNewline -Fore Cyan; Write-Host "Show info about interfaces"
        Write-host "$nt`8. " -NoNewline -Fore Cyan; Write-Host "Display all information"
        Write-host "$t   - Displays the entire collection of information about wireless 
             network adapters, wireless profiles and wireless networks"
        Write-host "$nt`9. " -NoNewline -Fore Cyan; Write-Host "Show available drivers"
        Write-host "$nt`10. " -NoNewline -Fore Cyan; Write-Host "Exit"

    #Gets input which is supposed to an integer value from the user
    [Int] $menuOption = Read-Host "`n`tOption"
        if ( $menuOption -lt 1 -or $menuOption -gt $LastOption ) {
			Write-Host "$nt`Please choose a number in the menu" -Fore Red
            Sleep -Seconds 2 #Script pauses for two seconds, so the user has time to read the error message
		}

        Write-Host "" #Shows the feedback to the user one line further down
    }

  Switch ( $menuOption ) {

    1 { #Option 1 - Configure Wifi HotSpot

        #First - Specify a network name
        Do {
            Write-Host "`tPlease specify the SSID (name) of network:" -Fore Cyan
            [string] $SSID = Read-Host "`n`tSSID"
                 if ($SSID -eq "") { Write-Host "`n`tThe name can't be empty!" -Fore Red }
        } while ($SSID -eq "")

        #Second - Specify a password for network
        Do {
            Write-Host "`n`tPlease specify a password for the network." -Fore Cyan
            Write-Host "`tPassword must contain at least eight characters." -Fore Cyan
            [string] $password = Read-Host "`n`tPassword"
                 if ($password -eq "") { Write-Host "`n`tThe field can't be empty!" -Fore Red }
                 if ($password.Length -lt 8) { Write-Host "`n`tThe password can't be less than eight characters!" -Fore Red }
        } while ($password -eq "" -or $password.Length -lt 8)

        #Third - Do you want to broadcast it?
        Do {
            Write-Host "`n`tDo you want to brodcast the SSID (name) of network? 'Y' for yes and 'N' for no" -Fore Cyan
            [string] $Answer = Read-Host "`n`tY/N"
                 if ($Answer -eq "" -or 
                     $Answer -ne "y" -and
                     $Answer -ne "n"
                 ) { Write-Host "`n`tPlease enter 'y' for yes or 'n' for no" -Fore Red }

        } while ($Answer -ne "y" -and $Answer -ne "n")
	
        If ($Answer -eq "n") { $broadcast_SSID = "disallow" }
        else { $broadcast_SSID = "allow" }

        Write-Host ""

        #Fourth - Create the network with specified settings
        Try {

            netsh wlan set hostednetwork mode=$broadcast_SSID ssid=$SSID key=$password
            If ($?) { Write-Host "`tCreated Wifi Hotspot '$SSID' sucessfully" -Fore Green }

        } Catch { #If something goes wrong a error message will be displayed
            Write-Host "`n`tSomething went wrong while creating the hotspot '$SSID'. Errormessage: " -Fore Yellow
            CatchErrorMessage
        }

        #Fourth - Start the network now?
        Do {
            Write-Host "`n`tDo you wish to start the new network now? 'Y' for yes and 'N' for no" -Fore Cyan
            [string] $Answer = Read-Host "`n`tY/N"
                 if ($Answer -eq "" -or 
                     $Answer -ne "y" -and
                     $Answer -ne "n"
                 ) { Write-Host "`n`tPlease enter 'Y' for yes and 'N' for no" -Fore Red }

        } while ($Answer -ne "y" -and $Answer -ne "n")

        #If user answered 'no' then go back to menu
        If ($Answer -eq "n") {
            Reload_menu_now
        }
        else { #Start the network
            Try {
                Write-Host ""
                netsh wlan start hostednetwork
                Prompt_reload_menu
            } Catch { CatchErrorMessage }
        }

    } #Option 1 - Configure Wifi HotSpot

    2 { #Option 2 - Start Wifi HotSpot
        Try { netsh wlan start hostednetwork; sleep 3 }
        Catch { CatchErrorMessage }
        Prompt_reload_menu

    } #Option 2 - Start Wifi HotSpot

    3 { #Option 3 - Stop Wifi HotSpot
        Try { netsh wlan stop hostednetwork }
        Catch { CatchErrorMessage }
        Prompt_reload_menu

    } #Option 3 - Stop Wifi HotSpot

    4 { #Option 4 - View hosted network settings

        Try { netsh wlan show hostednetwork }
        Catch { CatchErrorMessage }
        Prompt_reload_menu

    } #Option 4 - View hosted network settings

    5 { #Option 5 - Show Wireless LAN settings

        Try {
            netsh wlan show settings #Displays settings
            Prompt_reload_menu
        }
        Catch { CatchErrorMessage }
	    Prompt_reload_menu

    } #Option 5 - Show Wireless LAN settings

    6 { #Option 6 - display blocked networks

        Try { netsh wlan show blockednetworks }
        Catch { CatchErrorMessage }
        Prompt_reload_menu

    } #Option 6 - display blocked networks

    7 { #Option 7 - Show info about interfaces

        Try { netsh wlan show interfaces }

        Catch { CatchErrorMessage }

        Prompt_reload_menu

    } #Option 7 - Show info about interfaces

    8 { #Option 8 - Show info about interfaces

        Try { netsh wlan show all }
        Catch { CatchErrorMessage }
        Prompt_reload_menu

    } #Option 8 - Show info about interfaces

    9 { #Option 9 - Show available drivers

        Try {
            $Drivers = netsh wlan show drivers
                if ($Drivers) {

                    #Write-Host "`tFound folowing information" -Fore Green

                    $Drivers
                    #Write-Host "`tMake sure to check if the drivers support hosting a network`n" -Fore Yellow

                    if ($Drivers -match "Hosted network supported  : no") {
                        write-host "`tYou " -Fore Yellow -NoNewline
                        write-host "don't" -Fore Red -NoNewline
                        write-host " support hosting a network :(`n" -Fore Yellow
                    } Elseif ($Drivers -match "Hosted network supported  : yes") {
                        write-host "`tIt looks your driver support hosting wifi, nice!`n" -Fore Green
                    }
                    
                }
                else { Write-Host "`tCouldn't find any drivers" -Fore Red }
        } Catch { CatchErrorMessage }

        #Prompts the user to push 'enter' to go back to main menu
        Prompt_reload_menu

    } #Option 9 - Show available drivers
    
    default { #Code to execute if option number 10 is chosen 
        Write-Host "`t __________________ "
        Write-Host "`t<     Good bye     >"
        Write-Host "`t ------------------"
        Write-Host "`t        \   ^__^"
        Write-Host "`t         \  (oo)\_______"
        Write-Host "`t            (__)\       )\/\"
        Write-Host "`t                ||----w |"
        Write-Host "`t__v_v___v_____v_" -Fore Green -NoNewline
        Write-Host "||"                             -NoNewline
        Write-Host "_____"              -Fore Green -NoNewline
        Write-Host "||"                             -NoNewline
        Write-Host "__`n"               -Fore Green

        exit #Exits script

     } #Code to execute if option number 10 is chosen 

  }#End switch

}#End function

LoadMenu #Calls for the menu

