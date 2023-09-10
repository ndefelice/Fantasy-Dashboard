import requests
from fastapi import APIRouter

router = APIRouter()

# Get user ID
def init_user_id(username):

    user_url = "https://api.sleeper.app/v1/user/{}".format(username)
    response = requests.get(user_url)

    if response.status_code == requests.codes.ok:
        return response.json()['user_id']
    else:
        print("Error: Username is not valid.")


# Get league names and IDs
def get_leagues(username):
                   
    user_id = init_user_id(username)

    leagues_url = "https://api.sleeper.app/v1/user/{}/leagues/nfl/2023".format(user_id)
    response = requests.get(leagues_url)

    if response.status_code == requests.codes.ok:
        leagues = [{'league_name': league['name'], 'league_id': league['league_id']} for league in response.json()]

    return leagues


# Get roster ID for each league
def get_roster_id(username):

    leagues = get_leagues(username)

    rosters = []

    for league in leagues:
        league_id = league['league_id']
        rosters_url = "https://api.sleeper.app/v1/league/{}/rosters".format(league_id)

        response = requests.get(rosters_url)

        if response.status_code == requests.codes.ok:
            for roster in response.json():
                if roster['owner_id'] == init_user_id(username):
                    rosters.append({'league_name': league['league_name'], 'league_id': league['league_id'], 'roster_id': roster['roster_id']})

    return rosters


# Get roster names using the roster ID
def get_roster_name(league_id, roster_id):

    rosters_url = "https://api.sleeper.app/v1/league/{}/rosters".format(league_id)

    response = requests.get(rosters_url)

    if response.status_code == requests.codes.ok:
        for roster in response.json():
            if roster['roster_id'] == roster_id:
                user_id = roster['owner_id']

                users_url = "https://api.sleeper.app/v1/league/{}/users".format(league_id)

                response = requests.get(users_url)

                if response.status_code == requests.codes.ok:
                    for user in response.json():
                        if user['user_id'] == user_id:
                            return user['display_name']
                        

# Return the league name, matchup ID, team names, user score, and opponent score in JSON format.
# Do this for each league a user is in.
@router.get("/matchups/{sleeper_id}", tags=["Sleeper"])
def get_matchup_info(sleeper_id: str):
    
    rosters = get_roster_id(sleeper_id)

    scores = []

    for roster in rosters:

        league_id = roster['league_id']
        roster_id = roster['roster_id']
        
        matchups_url = "https://api.sleeper.app/v1/league/{}/matchups/1".format(league_id)

        response = requests.get(matchups_url)

        if response.status_code == requests.codes.ok:

            user_name = ''
            user_score = 0
            opp_name = ''
            opp_score = 0
            matchup_id = 0


            for matchup in response.json():
                if matchup['roster_id'] == roster_id:
                    user_score = matchup['points']
                    matchup_id = matchup['matchup_id']
                    user_name = get_roster_name(league_id, roster_id)
                    
            for matchup in response.json():
                if matchup['matchup_id'] == matchup_id and matchup['roster_id'] != roster_id:
                    opp_score = matchup['points']
                    opp_name = get_roster_name(league_id, matchup['roster_id'])
            
            scores.append({'league_name': roster['league_name'], 'matchup_id': matchup_id, 'user_name': user_name, 'user_score': user_score, 'opp_name': opp_name, 'opp_score': opp_score})

    return scores
