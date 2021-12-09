// Agent participant in project cnp

/* Initial beliefs and rules */

refuse :- .random(X) & X > 0.99.  // 1% chance of not answering

/* Initial goals */

!register.

/* Plans */

+!register
    <-  .df_register("participant");
        .df_subscribe("initiator");
        .

@answer_cfp
+cfp(ContractID,Task)[source(Agent)]
    :   provider(Agent,"initiator") &
        refuse
    <-  +proposal(ContractID,Task,Offer,Agent);
        .send(Agent,tell,refuse(ContractID));
		.
