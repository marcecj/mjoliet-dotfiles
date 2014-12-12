function pa_tunnel_to_marcec --description "Create a PA tunnel to marcec"

    # Pass the short host name to make this function independent of the
    # particular network used, i.e., independent of the domain name.
    pacmd load-module module-tunnel-sink-new.so \
        sink_name=marcec \
        server=marcec \
        sink=alsa_output.pci-0000_01_07.0.analog-stereo

end
