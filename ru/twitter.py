import sys
import tweepy

# # Authenticate to Twitter
api = tweepy.Client(bearer_token=sys.argv[5],
                    access_token=sys.argv[3],
                    access_token_secret=sys.argv[4],
                    consumer_key=sys.argv[1],
                    consumer_secret=sys.argv[2])

# auth = tweepy.OAuth1UserHandler(sys.argv[1], sys.argv[2])
# auth.set_access_token(sys.argv[3], sys.argv[4])

# # # Create API object
# api = tweepy.API(auth)

# # Create a tweet
message = """
"""+sys.argv[6]+"""

"""+sys.argv[8]+"""

#россия #украина #геноцид #нетвойне #StandWithUkraine #РоссияСмотри #RussiaInvadedUkraine #RussiaUkraineWar #RussianWarCrimes
"""    
api.create_tweet(text=message)

                