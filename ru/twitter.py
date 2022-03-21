import sys
import tweepy

# # Authenticate to Twitter
# api = tweepy.Client(bearer_token=sys.argv[5],
#                     access_token=sys.argv[3],
#                     access_token_secret=sys.argv[4],
#                     consumer_key=sys.argv[1],
#                     consumer_secret=sys.argv[2])

auth = tweepy.OAuth1UserHandler(
       sys.argv[1],
       sys.argv[2],
       sys.argv[3],
       sys.argv[4]
    )

api = tweepy.API(auth)

# auth = tweepy.OAuth1UserHandler(sys.argv[1], sys.argv[2])
# auth.set_access_token(sys.argv[3], sys.argv[4])

# # # Create API object
# api = tweepy.API(auth)
# upload
message = """
"""+sys.argv[6]+"""
"""+sys.argv[7]+"""
"""+sys.argv[8]+"""
"""+sys.argv[9]+"""
"""+sys.argv[10]+"""
"""    
messagefall = """
"""+sys.argv[7]+"""
"""+sys.argv[8]+"""
"""+sys.argv[9]+"""
"""+sys.argv[10]+"""
"""   
if (len(message) > 280):
   message=messagefall
messagefall2 = """
"""+sys.argv[7]+"""
"""+sys.argv[9]+"""
"""+sys.argv[10]+"""
""" 
if (len(message) > 280):
   message=messagefall2


if (len(sys.argv) > 10):
    media = api.media_upload(filename=sys.argv[11])
    tweet = api.update_status(status=message, media_ids= 
    [media.media_id_string])
else:
    tweet = api.update_status(status=message, media_ids= 
    [media.media_id_string])
     