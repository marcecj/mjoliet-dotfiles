function pa_tunnel_to_thetick --description "Create a PA tunnel to thetick"

    # Pass the short host name to make this function independent of the
    # particular network used, i.e., independent of the domain name.
    pacmd load-module module-tunnel-sink-new.so \
        sink_name=thetick \
        server=thetick \
        sink=alsa_output.pci-0000_01_07.0.analog-stereo

end
