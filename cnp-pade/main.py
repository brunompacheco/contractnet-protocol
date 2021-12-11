from sys import argv

from pade.misc.utility import start_loop
from pade.acl.aid import AID

from contractor import AgentContractor
from participant import AgentParticipant


if __name__ == "__main__":
    agents = list()

    port = int(argv[1])
    k = 1
    participants = list()

    for m in range(50):
        agent_name = 'agent_participant_{port}@localhost:{port}'.format(port=port+(m+1)*k)
        ag_participant = AgentParticipant(AID(name=agent_name))
        participants.append(agent_name)
        agents.append(ag_participant)

    for n in range(200):
        agent_name = 'agent_contractor_{port}@localhost:{port}'.format(port=port-n*k)
        ag_contractor = AgentContractor(AID(name=agent_name), participants, i=1)
        agents.append(ag_contractor)

    start_loop(agents)
