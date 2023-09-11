from pymfl.api import ScoringAndResultsAPIClient, SessionAPIClient
from pymfl.api.config import APIConfig

from fastapi import APIRouter

router = APIRouter()

@router.post("/mfl/username={username}/password={password}/agent={agent}/league_id={league_id}", tags=["MFL"])
def init_api_config(username: str, password: str, agent: str, league_id: str):
    APIConfig.add_config_for_year_and_league_id(
        year=2023,
        league_id=league_id,
        username=username,
        password=password,
        user_agent_name=agent
    )

    return {"message": "API successfully configurated!"}


@router.get("/mfl/{mfl_id}", tags=["MFL"])
def get_standings(mfl_id: str):

    scores = ScoringAndResultsAPIClient.get_live_scoring(year=2023, league_id=mfl_id)

    #Only return the scores of each team
    return [score['score'] for score in scores['liveScoring']['franchise']]