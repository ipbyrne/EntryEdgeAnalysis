# EntryEdgeAnalysis
This is an indicator template for MQL4 that measures the edge of a entry signal over time, providing a csv file that can be used to visualize the data in 6 different charts. Simply take the csv file produced by the indicator and paste it into the spread sheet provided and the charts will automatically populate.


In the example below, we are measuring the entry of an MA system that looks at the slopes of the moving averages in order to view how the edge of this entry plays out over time. The first 3 charts do not factor in using any Stop Loss or Take Profit. The last 3 charts look at how the entry signal performs using a fixed Stop Loss and Take Profit, specifically analyzing the MFE/MAE data.

## Break Down of Charts
Chart 1: Probability of Profit - This chart looks at the probability of closing the trade in a profit, if you were to hold for x amount of time.

![alt text](https://raw.githubusercontent.com/ipbyrne/EntryEdgeAnalysis/master/PROBABILITY%20OF%20PROFITABLE%20OUTCOME.png "POP")

Chart 2: This chart looks at the average MFE,  average MAE, and average Outcome of the entry for the corresponding holding periods on the x axis.

![alt text](https://raw.githubusercontent.com/ipbyrne/EntryEdgeAnalysis/master/avg-mae-mfe-outcome.png "AVG MAE/MFE/OUTCOME")

Chart 3: This chart uses the data from Chart 2 to produce the edge ratio as it progresses with the different hold times.

![alt text](https://raw.githubusercontent.com/ipbyrne/EntryEdgeAnalysis/master/e-ratio.png "E-Ratio")

Chart 4: This chart shows the winrate of the entry, using a fixed Stop Loss and fixed Take Profit. It also plots the break even winrate in yellow along with the break even winrate + spread risk in red. The spread risk is the amount of winrate you need to compensate for in order to break even based on the size of the spread relative to the range between your Stop Loss and Take Profit.

![alt text](https://raw.githubusercontent.com/ipbyrne/EntryEdgeAnalysis/master/WIN%20RATE.png "Win Rate")

Chart 5: This chart plots the average MAE/MFE data for the losing trades witht he fixed SL and TP so you can see how the losers progress.


![alt text](https://raw.githubusercontent.com/ipbyrne/EntryEdgeAnalysis/master/LOSING%20TRADES%20AVG%20MFE_MAE.png "Losing Trades")

Chart 6: This chart plots the average MAE/MFE data for the winning trades witht he fixed SL and TP so you can see how the winners progress.

![alt text](https://raw.githubusercontent.com/ipbyrne/EntryEdgeAnalysis/master/WINNING%20TRADES%20AVG%20MFE_MAE.png "Winning Trades")
