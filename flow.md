1. Oracle Publishes Pubkey, nonce_point, and outcome messages

2. Alice joins Coordinator server, sends Maker offer to Coordinator with 
    - Oracle Announcement
    - Chosen Outcome
    - Fund Fee
    - CET Fee
    - Coin to input
        - {prev_outpoint, prev_address, prev_amount}
    - Funding key & amount, change addresss
    - Settlement / Dest address

3. Bob joins Coordinator server.

4. Coordinator sends list of Maker offers (including Alice's) to Bob

4. Bob sends Taker offer to Coordinator, accepting Alice's terms. 
    - Oracle Announcement (will match Alice's)
    - chosen outcome
    - Coin to input
        - {prev_outpoint, prev_address, prev_amount}
    - Funding key & amount, change addresss
    - Settlement / Dest address

4. Alice and Bob receive "Match" notification from Coordinator, informing that their offers have been accepted/matched
    - fund amount
    - winner gets (implicitly includes odds)
    - outcomes 
    - dest scripts [list of scripts for each outcome]
        - these last two should be a map outcome -> list(script)

5. Alice and Bob receive one another's funding tx info from coordinator:
    - Coins to input
        - {prev_outpoint, prev_address, prev_amount}
    - Funding keys & amount
    - change outputs
    - dest addresses (for timeout scripts (TODO))

6. Alice and Bob each create the funding tx client side using the funding info

7. Alice and Bob each receive one another's CET info from Coordinator
    - Settlement / Dest address (already sent in funding tx info)

8. Alice and bob create CET transactions and send them to each other via coordinator:

9. Bob and Alice verify one another's CET txs, send confirmation to coordinator when verified

10. Bob and Alice each create Adaptor Signatures for each of the outcomes. Using the event outcome messages from the oracle directly, they can determine the Signature Points

11. Bob and Alice send the Adaptor Signatures to one another via the coordinator. 

12. Bob and Alice verify the other's encrypted signatures locally, send confirmation to coordinator when verified. 

13. Once verification from counterparty is received from coordinator,
both parties can sign the funding txid, send to coordinator to merge PSBTs and broadcast

14. once Funding txid has confirmations, alert alice & bob

15. When the Oracle broadcasts the event resolution, clients or coordinator should watch for it and notifes the coordinator, who relays the notif to the other counterparty. 

16. When a party receives the resolution, they decrypt the adaptor sigs for the appropriate outcome. 

17. Complete & broadcast tx