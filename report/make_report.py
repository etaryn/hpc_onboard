from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether

OUT = "report.pdf"   # run from report/: pip install reportlab; python make_report.py
ss = getSampleStyleSheet()
body = ParagraphStyle("b", parent=ss["Normal"], fontName="Helvetica", fontSize=9.5, leading=12.5, spaceAfter=4)
h1 = ParagraphStyle("h1", parent=ss["Heading1"], fontName="Helvetica-Bold", fontSize=15, spaceAfter=2)
h2 = ParagraphStyle("h2", parent=ss["Heading2"], fontName="Helvetica-Bold", fontSize=11.5, spaceBefore=8, spaceAfter=3)
cap = ParagraphStyle("c", parent=body, fontSize=8.5, leading=11, textColor=colors.HexColor("#444444"))
bul = ParagraphStyle("bu", parent=body, leftIndent=12, bulletIndent=2, spaceAfter=2)


def P(t): return Paragraph(t, body)
def B(t): return Paragraph(t, bul, bulletText="\u2022")


def table(rows, widths, bold_row=None):
    t = Table(rows, colWidths=[w * mm for w in widths], hAlign="LEFT")
    st = [("FONT", (0, 0), (-1, -1), "Helvetica", 8.5), ("FONT", (0, 0), (-1, 0), "Helvetica-Bold", 8.5),
          ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#e8eef5")),
          ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#b8c2cc")),
          ("TOPPADDING", (0, 0), (-1, -1), 2), ("BOTTOMPADDING", (0, 0), (-1, -1), 2),
          ("ALIGN", (1, 1), (-1, -1), "RIGHT")]
    if bold_row:
        st += [("FONT", (0, bold_row), (-1, bold_row), "Helvetica-Bold", 8.5),
               ("BACKGROUND", (0, bold_row), (-1, bold_row), colors.HexColor("#f3f7e8"))]
    t.setStyle(TableStyle(st))
    return t


s = []
s.append(Paragraph("HPL on the NUS SoC Compute Cluster: how we got 8.55 TFLOPS on two nodes", h1))
s.append(Paragraph("Kent Ridge HPC try-out, Option 1 (software benchmarking). Prepared by Bing Heng and Reyes, with help from Claude (Anthropic's AI assistant).", cap))
s.append(Spacer(1, 4))

s.append(P("<b>Result.</b> The best full-size run, run from the unpacked submission archive (<font face='Courier'>make</font>, then <font face='Courier'>make run</font>), "
           "reached <b>8549.9 GFLOPS</b> (N = 231,552, NB = 384, 968 s, residual check PASSED) on 2 xcni nodes. That is 58.8% of an "
           "<i>assumed</i> Rpeak of 14,540.8 GFLOPS. Three identical full-size runs scored 7701.6, 8309.3 and 8549.9 GFLOPS, an 11% spread "
           "on a shared cluster, so the number a reader sees will land somewhere in that range."))

s.append(Paragraph("1. Setup", h2))
s.append(B("<b>Hardware (xcni class).</b> 2 x AMD EPYC 9355 (Zen 5), 64 cores / 128 threads and 250 GB per node, AVX-512, 10 GbE "
           "(TCP only, no InfiniBand). The login nodes are no-AVX virtual machines, so nothing is tuned there and all builds run on a compute node via <font face='Courier'>srun</font>."))
s.append(B("<b>Software.</b> HPL 2.3, AOCL-BLIS 5.0 built as <i>amdzen</i> (one binary that picks its kernel at run time; it chose "
           "<i>zen5</i>), and a private Open MPI 4.1.6 with bundled PMIx/hwloc/libevent. One build serves both node types, so there is no <font face='Courier'>-march=native</font>."))
s.append(B("<b>Layout.</b> Hybrid MPI + OpenMP: 16 ranks per node x 4 threads, bound with <font face='Courier'>--map-by slot:PE=4 --bind-to core</font>, "
           "OMP_PLACES=cores, OMP_PROC_BIND=close. Each rank is given whole cores (hyper-thread siblings included) or Open MPI's core binding fails."))
s.append(B("<b>Rpeak (assumed).</b> 64 cores x 3.55 GHz x 32 DP FLOP/cycle = 7,270.4 GFLOPS per node, 14,540.8 for two. The 3.55 GHz "
           "base clock comes from the vendor spec and could not be read on the node (it exposes only a 4.4 GHz boost), and 32 FLOP/cycle assumes full-rate AVX-512. "
           "Percentages are therefore estimates."))

s.append(Paragraph("2. Constraints we ran into", h2))
s.append(B("<b>Two nodes, not four.</b> Slurm's QOS caps a user at 256 CPUs (<font face='Courier'>sacctmgr show qos</font>). One xcni node is 128 CPUs, so a "
           "3- or 4-node job sits in the queue with <font face='Courier'>QOSMaxCpuPerUserLimit</font> forever. We confirmed it with test jobs: 2 nodes (256 CPUs) ran, 3 (384) and 4 (512) stayed pending. "
           "Running 4 nodes at half the cores would use the same 256 CPUs but add network traffic, so we used 2 full nodes, which is also the task's minimum."))
s.append(B("<b>System Open MPI is unusable here</b> (PMIx segfaults, lost daemons), hence the private build and a launch with its own <font face='Courier'>mpirun</font> inside <font face='Courier'>sbatch</font>."))
s.append(B("<b>The first 2-node job hung.</b> The ranks sat at 99.9% CPU with about 10 MB resident each (no matrix allocated) and the log said "
           "<font face='Courier'>connect() to 192.168.58.21 failed</font>. Each node has two NICs and Open MPI picked the one on a subnet that is not routable between nodes. "
           "Pinning <font face='Courier'>btl_tcp_if_include</font> and <font face='Courier'>oob_tcp_if_include</font> to the working 192.168.48.0/21 fixed it. "
           "We used the subnet rather than an interface name so it holds on any node."))
s.append(B("Smaller things: <font face='Courier'>--exclusive</font> is refused and the default memory is 3 GB per CPU, so whole-node jobs need <font face='Courier'>--mem=0</font>; "
           "the xcng nodes are ARM, so every job is pinned with <font face='Courier'>--constraint=xcni</font>; Open MPI compiles on node-local /tmp because the NFS home is too slow."))

s.append(Paragraph("3. Tuning journey", h2))
s.append(P("One variable at a time, keeping a change only if it beat the run-to-run noise (about 1.5% at small N). "
           "We tuned on a single node first (N = 46,080), then on two nodes (N = 65,280 to 67,200) and confirmed on the full size."))

s.append(P("<b>Single node: block size, grid, ranks x threads</b> (GFLOPS)"))
s.append(table([["NB (64 ranks, 8x8)", "192", "256", "320", "384", "512"],
                ["GFLOPS", "2358", "2684", "3009", "3173", "2774"]], [38, 18, 18, 18, 18, 18], None))
s.append(Spacer(1, 3))
s.append(table([["Ranks x threads (NB 384)", "64x1", "32x2", "16x4", "8x8", "2x32"],
                ["GFLOPS", "3282", "3476", "3703", "3340", "2241"]], [38, 18, 18, 18, 18, 18], None))
s.append(Paragraph("Hybrid beats flat MPI by about 13% (16x4 vs 64x1). With 64 ranks the 4x16 grid beat 8x8 (3274 vs 3126), 16x4 (2400) and 2x32 (2921).", cap))

s.append(Spacer(1, 4))
i0 = len(s)
s.append(P("<b>Two nodes (32 ranks x 4 threads)</b>"))
s.append(table([["Grid P x Q (N 65280, NB 384)", "1x32", "2x16", "4x8", "4x4 (8 ranks x 8 thr)"],
                ["GFLOPS", "4560", "5901", "5222", "4677"]], [52, 18, 18, 18, 40], None))
s.append(Spacer(1, 3))
s.append(table([["NB (N 67200, 2x16)", "320", "384", "448"],
                ["GFLOPS", "5699", "5873", "5206"]], [52, 18, 18, 18], None))
s.append(Spacer(1, 3))
s.append(table([["BCAST (N 67200)", "1ring", "1ringM", "2ring", "2ringM", "Long", "LongM"],
                ["GFLOPS", "5859", "5923", "5727", "5796", "3683", "4227"]], [34, 18, 18, 18, 18, 18, 18], None))
s.append(Spacer(1, 3))
s.append(table([["DEPTH (N 67200)", "0", "1", "2"],
                ["GFLOPS", "5673", "5913", "5880"]], [34, 18, 18, 18], None))
s.append(Paragraph("Wide, flat grids win (P small, Q large) up to 2x16, where 1x32 falls off. NB = 384 is the sweet spot at both scales. "
                   "The default 1ring-modified broadcast and look-ahead depth 1 were already the best; the long (bandwidth-reducing) broadcasts lose 29-38%. "
                   "We did not sweep PFACT/RFACT/NBMIN/SWAP or the BLIS thread-partitioning variables; we expected under 2% there and stopped.", cap))

s[i0:] = [KeepTogether(s[i0:])]
s.append(Paragraph("4. Final numbers", h2))
s.append(table([["Run", "Config", "N", "Time (s)", "GFLOPS", "% Rpeak"],
                ["Best 1 node (tuning, 16x4, 4x4)", "1 node", "46,080", "17.6", "3702.8", "50.9"],
                ["Full size, in the repo (make run)", "2 nodes, 2x16", "231,552", "1074.7", "7701.6", "53.0"],
                ["Full size, clean-room test 1", "2 nodes, 2x16", "231,552", "996.1", "8309.3", "57.1"],
                ["Full size, clean-room test 2", "2 nodes, 2x16", "231,552", "968.1", "8549.9", "58.8"]],
               [58, 28, 20, 18, 18, 18], 4))
s.append(Paragraph("N = 231,552 is 80% of the 2 x 250 GiB of RAM, rounded down to a multiple of NB. Efficiency rises with N because communication takes a smaller share. "
                   "The 11% gap between identical full-size runs is not explained: we did not record which node pairs they used, and other users share the network. "
                   "We suspect contention or node differences but have not tested it.", cap))

s.append(Paragraph("5. Reproducibility", h2))
s.append(P("<font face='Courier'>make</font> builds BLIS, Open MPI and HPL from the source tarballs shipped in <font face='Courier'>dist/</font> (no internet needed; we ran it with a dead HTTP proxy to prove that) "
           "and took about 3 minutes from a clean unpack. <font face='Courier'>make run</font> submits with <font face='Courier'>sbatch --wait</font>, so it blocks until HPL finishes "
           "and then prints the result table. The submitted <font face='Courier'>config/HPL.dat</font> is the one used. "
           "The wall time of <font face='Courier'>make run</font> in our last test was 49 minutes, of which 16 minutes were HPL and the rest queue wait."))

s.append(Paragraph("6. What we learned", h2))
s.append(B("Check the scheduler's limits early. A QOS cap decided the whole shape of the run, and we only found it because a job sat pending with an unfamiliar reason code."))
s.append(B("Look at what the job is doing, not only whether it is running. Resident memory and CPU time per job separated a hung start-up (10 MB, spinning) from real work (tens of GB, growing CPU time) in under a minute."))
s.append(B("Two of our jobs overlapped once and one of them silently ran the other's <font face='Courier'>HPL.dat</font> (a 4x4 grid on 32 ranks, leaving half of them idle). "
           "The giveaway was memory: the whole matrix sat on one node. After that we ran one sweep at a time."))
s.append(B("On a 10 GbE link, grid shape and hybrid layout mattered more than any HPL algorithm knob. Large N also matters most: the same configuration went from 5.9 to 8.5 TFLOPS between N = 65k and N = 231k."))

SimpleDocTemplate(OUT, pagesize=A4, leftMargin=18 * mm, rightMargin=18 * mm, topMargin=15 * mm, bottomMargin=14 * mm,
                  title="HPL on the NUS SoC Compute Cluster", author="Bing Heng and Reyes").build(s)
print("ok")
