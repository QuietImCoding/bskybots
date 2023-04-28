# bskybots
A collection of bots for bluesky along with some systemd services to keep them running. Might include more devop-y stuff later

## Requirements

- `bsky` by mattn - https://github.com/mattn/bsky
- `jq` - https://stedolan.github.io/jq/

NOTE: You will need to log into bsky for all of these. You can use the command `bsky login <username> <password>` to do so.

## Additional Requirements
There are some additional requirements for specific bots, those will be listed in their respective README files. Currently bots that have extra steps are: 
- Honk Bot

## How to run
These are all bash scripts, so how you run them is up to you. Service files for _systemd_ are provided in case you want to throw them onto a server, but they have some assumptions specific to my server and likely need to be tweaked. The standard way to run one locally would be: 

```{bash}
bash beemoviebot/beemoviebot.sh &
disown
```

### If you want to set up services
You can run `bash setup.sh` and it will print all the commands you need to run to install and run the systemd services for you. Just copy and paste them back into the shell.

## Finally
Feel free to build whatever you want on these or deploy your own copies!!
If you do anything cool, tag me in a post @goose.art on bsky.social :3

