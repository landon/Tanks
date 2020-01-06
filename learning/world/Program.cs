using SharpNeat.EvolutionAlgorithms;
using SharpNeat.Genomes.Neat;
using System;
using System.Xml;

namespace world
{
    class Program
    {
        static NeatEvolutionAlgorithm<NeatGenome> _ea;

        static void Main(string[] args)
        {
            var experiment = new TanksExperiment();

            var xmlConfig = new XmlDocument();
            xmlConfig.Load("neatconfig.xml");

            experiment.Initialize("Tanks", xmlConfig.DocumentElement);
            _ea = experiment.CreateEvolutionAlgorithm();
            _ea.UpdateEvent += Ea_UpdateEvent;
            _ea.StartContinue();

            Console.ReadKey();
        }

        static void Ea_UpdateEvent(object sender, EventArgs e)
        {
            Console.WriteLine(string.Format("gen={0:N0} bestFitness={1:N6}", _ea.CurrentGeneration, _ea.Statistics._maxFitness));
        }
    }
}
