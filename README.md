## Gitweb & Docker
This an example how to run [Gitweb](https://git.wiki.kernel.org/index.php/Gitweb) in a docker container.

    git clone -b small https://github.com/elektret/gitweb.git gitweb
    cd gitweb

### Keypair
First generate a keypair or copy your public key to the ssh
directory and name it `gitweb_rsa`:

    rm -f gitweb_rsa.pub
    ssh-keygen -t rsa -b 4096 -f gitweb_rsa -C 'user@localhost'
    cp -iv gitweb_rsa gitweb_rsa.pub ~/.ssh/

### Tell git which key to use
In `~/.ssh/config`, add your key:

    cat >> ~/.ssh/config << EOF
    Host localhost
      Hostname localhost
      User gitweb
      IdentityFile ~/.ssh/gitweb_rsa
    EOF

### Build & run

    docker build -t elektret/gitweb-small
    docker run -dp 8080:80 -p 6060:22 --name some-gitweb elektret/gitweb-small
    
### Web interface
Your web interface should be accessible through `http://localhost:8080/`.
    
### Create a new remote repository

    ssh -i gitweb_rsa gitweb@localhost -p 6060
    git init --bare repos/project.git
    echo "Hello World" > repos/project.git/description
    exit

### Create a new local repository

    git init project.git
    cd project.git
    git remote add origin ssh://gitweb@localhost:6060/repos/project.git
    touch README.md
    git add README.md
    git commit -m 'First commit'
    git push -u origin master
