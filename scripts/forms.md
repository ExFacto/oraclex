
form 1: Initial info 
    - Initial coin:
        - Address currently in
        - Txid:vout of coin
        - amount 
    - Funding:
        - amount to put in
        - funding pubkey
    - Settlement:
        - destination address

Page 2: Summary

    The Bet:
    - Amounts into funding
    - Winner Gets
    - Fee paid to fund
    - Fee paid to settle

    The Funding Tx:
    - Script (as ASM)
    - Funding Address
    - Funding TXID

    CONFIRM

Page 3: CETs
    EAGLES CET:
    - TX

    CLICK CONFIRM (server-side signs :/ no alternative atm)

    CHIEFS CET: 
    - TX

    CLICK CONFIRM (server-side signs :/ no alterative atm)

Page 4: Adaptor Signatures
    for 4 x cet:
        <Adataptor Sig>

        VERIFY to verify, gives a true/false back

Page 5: 
    Please fund funding address
        Tx / psbt of funding tx

Page 6:
    Wait for Resolution!

    Signature & Resolution

    VERIFY sig

    EXTRACT s

    2 CET Adaptor Sigs:
    - Alice
        DECRYPT
    - bob
        DECRYPT

    SETTLE

    returns tx hex to settle

    