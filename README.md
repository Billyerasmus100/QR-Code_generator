# QR-Code_generator
Multi Field code generator 

Step 1: 
Insure that you have Docker installed 

Step 2 : 
Upload Files into desired DIR 

Step 3 :
change to DIR and execute
chmod+x on  fast-deploy.sh

Step 4:
run
./fast-deploy.sh

Take note that NPM may take a while you can monitor the process using command

docker exec qr-generator sh -c "tail -f /root/.npm/_logs/*.log 2>/dev/null || echo 'Installing...'"

wait for 10927 silly ADD node_modules/qrcode
10928 verbose cwd /app
10929 verbose os Linux 6.8.0-88-generic
10930 verbose node v18.20.8
10931 verbose npm  v10.8.2
10932 notice
10932 notice New major version of npm available! 10.8.2 -> 11.6.4
10932 notice Changelog: https://github.com/npm/cli/releases/tag/v11.6.4
10932 notice To update run: npm install -g npm@11.6.4
10932 notice  { force: true, [Symbol(proc-log.meta)]: true }
10933 verbose exit 0
10934 info ok

Step 5: 

You can nou access the webui 
http://url or IP:3000





