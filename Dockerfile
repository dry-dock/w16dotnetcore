# escape=`

FROM drydock/w16:master

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 2.1.500
ENV DOTNET_SDK_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-win-x64.zip
ENV DOTNET_SDK_DOWNLOAD_SHA C8A398773A517B7D36BC29895FC1C4B6B0D47CFDBED04D115FC75E8D0A4B7542B67C9125F701EC1C53038E846848F3C77CACAE2B61986E66164CFCA05005CA08

RUN Invoke-WebRequest $Env:DOTNET_SDK_DOWNLOAD_URL -OutFile dotnet.zip; `
    if ((Get-FileHash dotnet.zip -Algorithm sha512).Hash -ne $Env:DOTNET_SDK_DOWNLOAD_SHA) { `
        Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    Expand-Archive dotnet.zip -DestinationPath $Env:ProgramFiles\dotnet; `
    Remove-Item -Force dotnet.zip

RUN setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '\dotnet')

# Trigger the population of the local package cache
ENV NUGET_XMLDOC_MODE skip
RUN New-Item -Type Directory warmup; `
    cd warmup; `
    dotnet new; `
    cd ..; `
    Remove-Item -Force -Recurse warmup
