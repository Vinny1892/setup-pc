function sunshine
    switch $argv[1]
        case on
            niri msg output DP-2 on
            niri msg output DP-2 scale 1
            sleep 1
            sudo ufw allow 47984/tcp
            sudo ufw allow 47989/tcp
            sudo ufw allow 47990/tcp
            sudo ufw allow 48010/tcp
            sudo ufw allow 47998:48000/udp
            systemctl --user start sunshine
        case off
            systemctl --user stop sunshine
            niri msg output DP-2 off
            sudo ufw delete allow 47984/tcp
            sudo ufw delete allow 47989/tcp
            sudo ufw delete allow 47990/tcp
            sudo ufw delete allow 48010/tcp
            sudo ufw delete allow 47998:48000/udp
        case status
            systemctl --user status sunshine --no-pager
        case '*'
            echo "uso: sunshine on | off | status"
    end
end
