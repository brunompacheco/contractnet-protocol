from sys import argv

from pade.misc.utility import start_loop
from pade.acl.aid import AID

from contractor import AgentContractor
from participant import AgentParticipant


if __name__ == "__main__":
    agents = list()

    port = int(argv[1])
    k = 10000
    participants = list()

    for i in range(2):
        agent_name = 'agent_participant_{port}@localhost:{port}'.format(port=port+(i+1)*k)
        ag_participant = AgentParticipant(AID(name=agent_name))
        participants.append(agent_name)
        agents.append(ag_participant)

    agent_name = 'agent_contractor_{port}@localhost:{port}'.format(port=port)
    ag_contractor = AgentContractor(AID(name=agent_name), participants)
    agents.append(ag_contractor)

    start_loop(agents)