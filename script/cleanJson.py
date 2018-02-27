def main(argv):
    inf=str(argv[1])
    outf="./visNetwork/net.json"
    outfile=open(outf,"w")
    infile=open(inf,"r")
    infile.readline()

    header='{\n"directed": false, \n"graph": {\n"node_default": {}, \n"edge_default": {}\n}, \n"nodes": [\n{'

    outfile.write(header)

    for line in infile:
        s=line
        n=re.sub(r'\"','',s.strip().split(":")[-1]).lstrip()
        out=re.sub(r'\"\s*[0-9]+\",', n,s)
        outfile.write(out)
    outfile.close()

if __name__ == "__main__":
    import sys
    import re
    main(sys.argv)
