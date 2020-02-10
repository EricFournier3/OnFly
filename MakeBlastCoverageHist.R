args <- commandArgs(trailingOnly = TRUE)
in_dat = args[1]
out_graph = args[2]
suppressMessages(library(tidyverse))

library(tidyverse)

my_dat <- read_tsv(in_dat, col_names = TRUE)
my_dat2 <- my_dat %>% group_by(PlasmidAcc) %>% summarise(AlignmentLengthSum = sum(AlignmentLength), PlasmidLength = max(PlasmidLength), Cov = (AlignmentLengthSum/PlasmidLength)*100000) %>% filter(Cov > 50000)

pdf(NULL)

ggplot(data = my_dat2 %>% gather(Metric,Value,-PlasmidAcc), aes(x=PlasmidAcc,y=Value,fill=Metric)) + geom_bar(width=0.4, stat = 'identity', position = 'dodge') + theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 5))

ggsave(out_graph, device = "pdf")

