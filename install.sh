
sudo mkdir /home/cjmartin/installed-scripts/sequence-rename/
sudo cp ./seqren.sh /home/cjmartin/installed-scripts/sequence-rename/
sudo chmod +x /home/cjmartin/installed-scripts/sequence-rename/seqren.sh
echo "alias seqren='/home/cjmartin/installed-scripts/sequence-rename/seqren.sh'" >> ~/.bashrc
echo "Script is located at \"/home/cjmartin/installed-scripts/sequence-rename/\""
echo "~/.bashrc updated"
echo "Run\n> seqren -h\nTo check for functionality"
