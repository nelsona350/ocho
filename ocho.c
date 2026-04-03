#include <stdio.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>

int	numberOfMatches,numberOfBallsRemaining,ball[8],hole[8];
void	rollBalls();

main(argc,argv)
int	argc;
char	*argv[];
{
	int	i,j,nturns,goodInitialRoll,max_turns=10;
	double	mvalue=1.,score,total_score;
	char ans[2];
	
//	Seed the random-number generator with current time so that
//	the numbers will be different every time we run.

	srand( (unsigned)time( NULL ) );
	rand();

//	game initialization

	nturns = 1;
	total_score = 0.;
	numberOfBallsRemaining = 8;
	goodInitialRoll = 0;

//	initialize the ball and hole arrays - the balls are numbered 1 through 8

	for(i=0;i<8;i++)
	{
	     	ball[i] = i+1;
	     	hole[i] = 0;
	}

	while(nturns<=max_turns)
	{


//		initial roll

		while(goodInitialRoll == 0)
		{
	
			numberOfBallsRemaining = 8;
			for(i=0;i<8;i++)
			{
	     			ball[i] = i+1;
	     			hole[i] = 0;
			}
			rollBalls();
			if(numberOfMatches>0) goodInitialRoll = 1;
		
		}

//		print data and compute score

		printf("\n\n\n\n\n\n\n\n");
		score = 0.;
		for(i=0;i<8;i++)
		{
			if (hole[i] == i+1)
			{
				printf("\t%d  %d  M\n",i+1,i+1);
				score += (i+1) * mvalue;
			}
			else
			{
				printf("\t%d  %d\n",i+1,hole[i]);
			}
		}

//		clear holes that are not matches and reload ball array

		j = 0;
		for(i=0;i<8;i++)
		{
			if (hole[i] != i+1)
			{
				ball[j] = hole[i];
				hole[i] = 0;
				j++;
			}
		}

//		print score

		printf("\nScores: Turn %d = %lf\tTotal = %lf\n\n",nturns,score,total_score);

//		check for match given back or end of turn request

		if(numberOfMatches > 0)
		{
			printf("Give back a match to roll again (0 to stop) ");
			scanf("%d",&i);
			while(hole[i-1]==0 && i!=0)
			{
				printf("Not a match\n");
				scanf("%d",&i);
			}

		}

		if (i != 0 && numberOfMatches > 0)
		{

//			give back match and roll again

			hole[i-1] = 0;
			numberOfMatches--;
			ball[7-numberOfMatches] = i;
			numberOfBallsRemaining = 8 - numberOfMatches;
			rollBalls();
		}
		else
		{

//			end of turn

			total_score += score;
			printf("\n\nEnd of turn %d - total score = %lf\n\n",nturns,total_score);
			nturns++;
			numberOfBallsRemaining = 8;
			goodInitialRoll = 0;
			for(i=0;i<8;i++)
			{
	     			ball[i] = i+1;
	     			hole[i] = 0;
			}
			printf("Next turn? ");
			scanf("%s",ans);
			while (ans[0] != '0') scanf("%s",ans);
		}
	}

	printf("\n\n***********  Game Over: Final Score = %lf  ***********\n",total_score);

	exit(0);
}

// ---------------------------------------------------------------------------------------
void	rollBalls()
{
	int k,i,j,n;

//	draw a ball for each unmatched hole

	k = 0;
	for(i=0;i<8;i++)
	{
	
//		is hole empty?
		
		if (hole[i] == 0)
		{

//			draw from remaining balls

			n = numberOfBallsRemaining * rand() / 32768;
			hole[i] = ball[n];
			numberOfBallsRemaining--;

//			shift ball array

			for(j=n;j<numberOfBallsRemaining;j++) ball[j] = ball[j+1];
		}
	}

//	count numberOfMatches

	j = 0;
	numberOfMatches = 0;
	for(i=0;i<8;i++)
	{
		if (hole[i] == i+1) numberOfMatches++;
	}

	return;
}
