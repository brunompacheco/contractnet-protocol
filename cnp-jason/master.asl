// Agent master in project contractnet.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true
	<-	.wait(1000);  // wait for participants to register
		.print("creating contractors.");
		for ( .range(M,1,2) ) {
			.create_agent(Contractor,"contractor.asl");
			.send(Contractor,tell,id(M));
		}
		.

